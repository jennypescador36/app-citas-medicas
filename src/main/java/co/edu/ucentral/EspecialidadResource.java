package co.edu.ucentral;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

/**
 * HU006 - Consulta de especialidades medicas, sus profesionales y disponibilidad.
 */
@Path("/api")
@Produces(MediaType.APPLICATION_JSON)
public class EspecialidadResource {

    private static final Locale ES = Locale.forLanguageTag("es-CO");
    static final DateTimeFormatter HORA = DateTimeFormatter.ofPattern("HH:mm");

    @Inject
    AgendaService agenda;

    /** Especialidades activas con la cantidad de profesionales activos. */
    @GET
    @Path("/especialidades")
    public List<Map<String, Object>> listarEspecialidades() {
        return Especialidad.listarActivas().stream().map(e -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", e.id);
            m.put("nombre", e.nombre);
            m.put("descripcion", e.descripcion);
            m.put("cantidadProfesionales", Profesional.count("especialidad.id = ?1 and activo = true", e.id));
            return m;
        }).collect(Collectors.toList());
    }

    /** Profesionales activos de una especialidad, con su informacion basica y proxima disponibilidad. */
    @GET
    @Path("/especialidades/{id}/profesionales")
    public Response listarProfesionales(@PathParam("id") Long id) {
        Especialidad especialidad = Especialidad.findById(id);
        if (especialidad == null || Boolean.FALSE.equals(especialidad.activa)) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity(Map.of("mensaje", "La especialidad no existe o no está activa"))
                    .build();
        }
        List<Map<String, Object>> profesionales = Profesional.listarActivosPorEspecialidad(id).stream()
                .map(this::aMapa)
                .collect(Collectors.toList());
        return Response.ok(profesionales).build();
    }

    /** Fechas y horas libres del profesional en los proximos dias. */
    @GET
    @Path("/profesionales/{id}/disponibilidad")
    public Response disponibilidad(@PathParam("id") Long id) {
        Profesional p = Profesional.findById(id);
        if (p == null || !p.estaActivo()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity(Map.of("mensaje", "El profesional no existe o no está activo"))
                    .build();
        }
        return Response.ok(disponibilidadComoLista(p, null)).build();
    }

    List<Map<String, Object>> disponibilidadComoLista(Profesional p, Long excluirCitaId) {
        List<Map<String, Object>> dias = new ArrayList<>();
        for (Map.Entry<LocalDate, List<LocalTime>> e : agenda.disponibilidad(p, excluirCitaId).entrySet()) {
            Map<String, Object> dia = new LinkedHashMap<>();
            dia.put("fecha", e.getKey().toString());
            dia.put("diaSemana", e.getKey().getDayOfWeek().getDisplayName(TextStyle.FULL, ES));
            dia.put("horas", e.getValue().stream().map(HORA::format).collect(Collectors.toList()));
            dias.add(dia);
        }
        return dias;
    }

    Map<String, Object> aMapa(Profesional p) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", p.id);
        m.put("nombre", p.nombre);
        m.put("registroMedico", p.registroMedico);
        m.put("correo", p.correo);
        m.put("consultorio", p.consultorio);
        m.put("especialidadId", p.especialidad.id);
        m.put("especialidad", p.especialidad.nombre);
        m.put("diasAtencion", p.getDias().stream().sorted()
                .map(d -> d.getDisplayName(TextStyle.SHORT, ES))
                .collect(Collectors.joining(", ")));
        m.put("horario", HORA.format(p.horaInicio) + " - " + HORA.format(p.horaFin));

        // Proxima cita libre (o null si no hay disponibilidad en los proximos dias)
        Map<LocalDate, List<LocalTime>> disp = agenda.disponibilidad(p, null);
        if (disp.isEmpty()) {
            m.put("proximaDisponibilidad", null);
            m.put("horariosLibres", 0);
        } else {
            Map.Entry<LocalDate, List<LocalTime>> primero = disp.entrySet().iterator().next();
            m.put("proximaDisponibilidad", primero.getKey().atTime(primero.getValue().get(0)).toString());
            m.put("horariosLibres", disp.values().stream().mapToInt(List::size).sum());
        }
        return m;
    }
}
