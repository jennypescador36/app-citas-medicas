package co.edu.ucentral;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

/**
 * Vista del medico: pacientes que tiene asignados (tienen o tuvieron cita con el)
 * y las citas de cada uno en orden ascendente por fecha.
 */
@Path("/api/medicos")
@Produces(MediaType.APPLICATION_JSON)
public class MedicoResource {

    @Inject
    MedicoService medicoService;

    @Inject
    AgendaService agenda;

    @GET
    @Path("/{idUsuario}/pacientes")
    @Transactional
    public Response pacientesAsignados(@PathParam("idUsuario") Long idUsuario) {
        Usuario medico = Usuario.findById(idUsuario);
        if (medico == null || !medicoService.esMedico(medico)) {
            return CitaResource.error(Response.Status.NOT_FOUND, "El usuario no es un profesional de la salud");
        }
        Profesional profesional = medicoService.vincular(medico);
        if (profesional == null) {
            return CitaResource.error(Response.Status.CONFLICT, "No hay especialidades configuradas para asociar al médico");
        }

        List<Cita> citas = Cita.list("idProfesional = ?1 order by fechaInicio asc, id asc", profesional.id);
        Map<Long, List<Cita>> porPaciente = citas.stream()
                .collect(Collectors.groupingBy(c -> c.idUsuario, LinkedHashMap::new, Collectors.toList()));

        LocalDateTime ahora = agenda.ahora();
        List<Map<String, Object>> pacientes = new ArrayList<>();
        for (Map.Entry<Long, List<Cita>> e : porPaciente.entrySet()) {
            Usuario paciente = Usuario.findById(e.getKey());
            if (paciente == null) {
                continue;
            }
            List<Cita> suyas = e.getValue();
            Cita proxima = suyas.stream()
                    .filter(c -> "PROGRAMADA".equalsIgnoreCase(c.estado) && c.fechaInicio != null
                            && c.fechaInicio.isAfter(ahora))
                    .findFirst().orElse(null);

            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", paciente.id);
            m.put("nombre", paciente.nombre);
            m.put("documento", paciente.documento);
            m.put("correo", paciente.correo);
            m.put("totalCitas", suyas.size());
            m.put("proximaCita", proxima == null ? null : proxima.fechaHora);
            m.put("proximaCitaInicio", proxima == null ? null : proxima.fechaInicio.toString());
            m.put("citas", suyas.stream().map(c -> {
                Map<String, Object> cm = new LinkedHashMap<>();
                cm.put("id", c.id);
                cm.put("especialidad", c.especialidad);
                cm.put("fechaHora", c.fechaHora);
                cm.put("fechaInicio", c.fechaInicio == null ? null : c.fechaInicio.toString());
                cm.put("estado", c.estado);
                return cm;
            }).collect(Collectors.toList()));
            pacientes.add(m);
        }
        // Primero los que tienen proxima cita (la mas cercana primero), luego el resto por nombre
        pacientes.sort(Comparator
                .comparing((Map<String, Object> m) -> m.get("proximaCitaInicio") == null)
                .thenComparing(m -> m.get("proximaCitaInicio") == null ? "" : (String) m.get("proximaCitaInicio"))
                .thenComparing(m -> ((String) m.get("nombre")).toLowerCase()));

        Map<String, Object> respuesta = new LinkedHashMap<>();
        respuesta.put("idProfesional", profesional.id);
        respuesta.put("nombre", profesional.nombre);
        respuesta.put("especialidad", profesional.especialidad.nombre);
        respuesta.put("consultorio", profesional.consultorio);
        respuesta.put("horario", EspecialidadResource.HORA.format(profesional.horaInicio) + " - "
                + EspecialidadResource.HORA.format(profesional.horaFin));
        respuesta.put("pacientes", pacientes);
        return Response.ok(respuesta).build();
    }
}
