package co.edu.ucentral;

import java.time.LocalTime;

import io.quarkus.runtime.StartupEvent;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

/**
 * Carga especialidades y profesionales de ejemplo la primera vez que arranca
 * el backend (si la tabla de especialidades esta vacia). Funciona igual en local y en Render.
 */
@ApplicationScoped
public class DatosIniciales {

    @Inject
    MedicoService medicoService;

    @Inject
    CitasDemo citasDemo;

    @Transactional
    void alIniciar(@Observes StartupEvent evento) {
        if (Especialidad.count() == 0) {
            cargarEspecialidadesYProfesionales();
        }
        // Cada usuario SALUD queda asociado a un profesional (idempotente)
        medicoService.vincularTodos();
        // Citas de ejemplo para los pacientes existentes (solo la primera vez)
        citasDemo.cargarSiHaceFalta();
    }

    private void cargarEspecialidadesYProfesionales() {

        Especialidad general = especialidad("Medicina General",
                "Consulta de primer nivel para valoración, diagnóstico y remisión.");
        Especialidad pediatria = especialidad("Pediatría",
                "Atención médica de niños y adolescentes.");
        Especialidad cardiologia = especialidad("Cardiología",
                "Prevención, diagnóstico y tratamiento de enfermedades del corazón.");
        Especialidad dermatologia = especialidad("Dermatología",
                "Cuidado de la piel, cabello y uñas.");
        Especialidad odontologia = especialidad("Odontología",
                "Salud oral, limpiezas y tratamientos dentales.");
        // Especialidad activa sin profesionales: la app debe informar que no hay disponibilidad
        especialidad("Nutrición", "Planes de alimentación y control de peso.");

        profesional("Laura Gómez", "RM-10234", general, "101", "1,2,3,4,5", 8, 12);
        profesional("Carlos Ramírez", "RM-10871", general, "102", "1,2,3,4,5", 14, 18);
        profesional("Andrea Torres", "RM-20456", pediatria, "201", "1,3,5", 8, 12);
        profesional("Miguel Herrera", "RM-20987", pediatria, "202", "2,4,6", 9, 13);
        profesional("Sofía Castro", "RM-30112", cardiologia, "301", "1,2,4", 7, 11);
        profesional("Daniel Rojas", "RM-40321", dermatologia, "401", "2,3,5", 13, 17);
        profesional("Valentina Díaz", "RM-50678", odontologia, "501", "1,2,3,4,5,6", 8, 12);
    }

    private Especialidad especialidad(String nombre, String descripcion) {
        Especialidad e = new Especialidad();
        e.nombre = nombre;
        e.descripcion = descripcion;
        e.activa = true;
        e.persist();
        return e;
    }

    private void profesional(String nombre, String registro, Especialidad esp, String consultorio,
            String dias, int horaInicio, int horaFin) {
        Profesional p = new Profesional();
        p.nombre = nombre;
        p.registroMedico = registro;
        p.correo = java.text.Normalizer.normalize(nombre, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "").toLowerCase().replace(' ', '.') + "@medicalcenter.co";
        p.consultorio = "Consultorio " + consultorio;
        p.especialidad = esp;
        p.diasAtencion = dias;
        p.horaInicio = LocalTime.of(horaInicio, 0);
        p.horaFin = LocalTime.of(horaFin, 0);
        p.duracionMinutos = 30;
        p.activo = true;
        p.persist();
    }
}
