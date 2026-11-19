package co.edu.ucentral;

import java.time.LocalTime;
import java.util.List;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Asocia cada usuario de tipo SALUD con un registro de Profesional,
 * para que pueda recibir citas y ver los pacientes que tiene asignados.
 */
@ApplicationScoped
public class MedicoService {

    /** Especialidades que se asignan en orden a los medicos registrados en la app. */
    private static final List<String> ESPECIALIDADES_MEDICOS =
            List.of("Medicina General", "Cardiología", "Dermatología", "Pediatría", "Odontología");

    public boolean esMedico(Usuario u) {
        return u != null && "SALUD".equalsIgnoreCase(u.tipoUsuario);
    }

    /** Devuelve el profesional del usuario, creandolo si aun no existe. Requiere transaccion. */
    public Profesional vincular(Usuario usuario) {
        Profesional existente = Profesional.findByUsuario(usuario.id);
        if (existente != null) {
            return existente;
        }
        long yaVinculados = Profesional.count("idUsuario is not null");
        String nombreEsp = ESPECIALIDADES_MEDICOS.get((int) (yaVinculados % ESPECIALIDADES_MEDICOS.size()));
        Especialidad esp = Especialidad.find("nombre", nombreEsp).firstResult();
        if (esp == null) {
            esp = Especialidad.find("activa = true order by id").firstResult();
        }
        if (esp == null) {
            return null;
        }

        Profesional p = new Profesional();
        p.nombre = usuario.nombre;
        p.idUsuario = usuario.id;
        p.correo = usuario.correo;
        p.registroMedico = "RM-" + usuario.documento;
        p.consultorio = "Consultorio " + (600 + yaVinculados);
        p.especialidad = esp;
        p.diasAtencion = "1,2,3,4,5";
        p.horaInicio = LocalTime.of(8, 0);
        p.horaFin = LocalTime.of(16, 0);
        p.duracionMinutos = 30;
        p.activo = true;
        p.persist();
        return p;
    }

    /** Vincula a todos los usuarios SALUD que aun no tienen profesional. */
    public void vincularTodos() {
        List<Usuario> medicos = Usuario.list("upper(tipoUsuario) = 'SALUD' order by id");
        for (Usuario u : medicos) {
            vincular(u);
        }
    }
}
