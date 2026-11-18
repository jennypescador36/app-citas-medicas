package co.edu.ucentral;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import jakarta.inject.Inject;
import jakarta.persistence.LockModeType;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/citas")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CitaResource {

    @Inject
    AgendaService agenda;

    private static final DateTimeFormatter FORMATO_SALIDA =
            DateTimeFormatter.ofPattern("dd/MM/yyyy - hh:mm a", Locale.US);

    private static final List<DateTimeFormatter> FORMATOS_ENTRADA = List.of(
            DateTimeFormatter.ofPattern("dd/MM/yyyy - hh:mm a", Locale.US),
            DateTimeFormatter.ofPattern("d/M/yyyy - h:mm a", Locale.US),
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")
    );

    @GET
    @Path("/usuario/{idUsuario}")
    public Response obtenerCitasPorUsuario(@PathParam("idUsuario") Long idUsuario) {
        List<Cita> citas = Cita.listByUsuario(idUsuario);
        if (citas.isEmpty()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("No se encontraron citas para el usuario.")
                    .build();
        }

        // Normalizar el formato de fecha_hora y ordenar cronológicamente ascendente
        for (Cita cita : citas) {
            cita.fechaHora = normalizarFechaTexto(cita.fechaHora);
        }

        citas.sort(Comparator.comparing(cita -> parsearFecha(cita.fechaHora)));

        return Response.ok(citas).build();
    }

    @POST
    @Transactional
    public Response crearCita(Cita cita) {
        if (cita.estado == null || cita.estado.isEmpty()) {
            cita.estado = "PROGRAMADA";
        }
        if (cita.fechaHora != null && !cita.fechaHora.isBlank()) {
            cita.fechaHora = normalizarFechaTexto(cita.fechaHora);
        }
        cita.persist();
        return Response.status(Response.Status.CREATED).entity(cita).build();
    }

    /**
     * HU008 - Agendamiento de cita: especialidad (por el profesional), profesional, fecha y hora.
     * Verifica de nuevo la disponibilidad, que el paciente no tenga otra cita a esa hora
     * y deja el horario ocupado al registrar la cita como PROGRAMADA.
     */
    @POST
    @Path("/agendar")
    @Transactional
    public Response agendarCita(AgendarRequest req) {
        if (req == null || req.idUsuario == null || req.idProfesional == null
                || req.fecha == null || req.hora == null) {
            return error(Response.Status.BAD_REQUEST, "Debe seleccionar especialidad, profesional, fecha y hora");
        }
        Usuario paciente = Usuario.findById(req.idUsuario);
        if (paciente == null || !paciente.estaActivo()) {
            return error(Response.Status.NOT_FOUND, "El paciente no existe o su cuenta no esta activa");
        }
        // Bloqueo del profesional: dos pacientes no pueden tomar el mismo horario a la vez
        Profesional profesional = Profesional.findById(req.idProfesional, LockModeType.PESSIMISTIC_WRITE);
        if (profesional == null || !profesional.estaActivo()) {
            return error(Response.Status.NOT_FOUND, "El profesional no existe o no esta activo");
        }
        LocalDateTime inicio = parsearFechaHora(req.fecha, req.hora);
        if (inicio == null) {
            return error(Response.Status.BAD_REQUEST, "Fecha u hora con formato invalido (yyyy-MM-dd y HH:mm)");
        }
        String problema = agenda.validarHorario(profesional, inicio, null);
        if (problema != null) {
            return error(Response.Status.CONFLICT, problema);
        }
        if (Cita.pacienteOcupado(paciente.id, inicio, null)) {
            return error(Response.Status.CONFLICT, "Ya tienes otra cita programada en ese mismo horario");
        }

        Cita cita = new Cita();
        cita.idUsuario = paciente.id;
        cita.idProfesional = profesional.id;
        cita.especialidad = profesional.especialidad.nombre;
        cita.medico = profesional.nombre;
        cita.fechaInicio = inicio;
        cita.fechaHora = inicio.format(FORMATO_SALIDA).toUpperCase(Locale.US);
        cita.estado = "PROGRAMADA";
        cita.persist();

        return Response.status(Response.Status.CREATED).entity(detalle(cita)).build();
    }

    /** Cita con los datos del profesional (consultorio, registro) para mostrar en la app. */
    Map<String, Object> detalle(Cita cita) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", cita.id);
        m.put("idUsuario", cita.idUsuario);
        m.put("idProfesional", cita.idProfesional);
        m.put("especialidad", cita.especialidad);
        m.put("medico", cita.medico);
        m.put("fechaHora", cita.fechaHora);
        m.put("fechaInicio", cita.fechaInicio == null ? null : cita.fechaInicio.toString());
        m.put("estado", cita.estado);
        Profesional p = cita.idProfesional == null ? null : Profesional.findById(cita.idProfesional);
        m.put("consultorio", p == null ? null : p.consultorio);
        return m;
    }

    static LocalDateTime parsearFechaHora(String fecha, String hora) {
        try {
            return LocalDate.parse(fecha.trim()).atTime(LocalTime.parse(hora.trim()));
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    static Response error(Response.Status status, String mensaje) {
        return Response.status(status).entity(Map.of("mensaje", mensaje)).build();
    }

    private LocalDateTime parsearFecha(String fechaTexto) {
        if (fechaTexto == null || fechaTexto.isBlank()) {
            return LocalDateTime.MAX;
        }
        String limpia = fechaTexto.trim().toUpperCase(Locale.US);
        for (DateTimeFormatter formatter : FORMATOS_ENTRADA) {
            try {
                return LocalDateTime.parse(limpia, formatter);
            } catch (Exception ignored) {
            }
        }
        return LocalDateTime.MAX;
    }

    private String normalizarFechaTexto(String fechaTexto) {
        LocalDateTime fecha = parsearFecha(fechaTexto);
        if (fecha.equals(LocalDateTime.MAX)) {
            return fechaTexto;
        }
        return fecha.format(FORMATO_SALIDA).toUpperCase(Locale.US);
    }
}