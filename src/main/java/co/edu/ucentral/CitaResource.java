package co.edu.ucentral;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

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