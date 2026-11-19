package co.edu.ucentral;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

/**
 * Carga UNA SOLA VEZ citas de ejemplo para los pacientes que ya existen:
 * una ATENDIDA, una FINALIZADA y una CANCELADA (fechas pasadas) y una PROGRAMADA (fecha futura libre),
 * repartidas entre los medicos registrados en la app para que cada uno tenga pacientes asignados.
 * La marca queda en la tabla parametro y no se repite aunque el servidor reinicie.
 */
@ApplicationScoped
public class CitasDemo {

    static final String CLAVE = "citas_demo_cargadas";
    private static final DateTimeFormatter FORMATO =
            DateTimeFormatter.ofPattern("dd/MM/yyyy - hh:mm a", Locale.US);

    @Inject
    AgendaService agenda;

    /** Requiere transaccion. */
    public void cargarSiHaceFalta() {
        if (Parametro.existe(CLAVE)) {
            return;
        }
        List<Profesional> medicos = Profesional.list("idUsuario is not null and activo = true order by id");
        if (medicos.isEmpty()) {
            medicos = Profesional.list("activo = true order by id");
        }
        List<Usuario> pacientes = Usuario.list("upper(tipoUsuario) = 'PACIENTE' order by id");
        if (medicos.isEmpty() || pacientes.isEmpty()) {
            return; // se intentara de nuevo en el siguiente arranque
        }

        int turno = 0;
        int creadas = 0;
        for (int i = 0; i < pacientes.size(); i++) {
            Usuario paciente = pacientes.get(i);
            // Citas pasadas: hace 30, 20 y 10 dias aprox.
            String[] estadosPasados = {"ATENDIDA", "FINALIZADA", "CANCELADA"};
            int[] diasAtras = {30, 20, 10};
            for (int k = 0; k < estadosPasados.length; k++) {
                Profesional p = medicos.get(turno++ % medicos.size());
                LocalDateTime inicio = diaAtendidoAntesDe(p, LocalDate.now(AgendaService.ZONA).minusDays(diasAtras[k] + i))
                        .atTime(p.horaInicio.plusMinutes((long) p.duracionMinutos * (i % 4)));
                if (!Cita.pacienteOcupado(paciente.id, inicio, null)) {
                    crear(paciente, p, inicio, estadosPasados[k]);
                    creadas++;
                }
            }
            // Cita futura PROGRAMADA en el primer horario libre del medico
            Profesional p = medicos.get(turno++ % medicos.size());
            LocalDateTime futura = primerHorarioLibre(p, paciente);
            if (futura != null) {
                crear(paciente, p, futura, "PROGRAMADA");
                creadas++;
            }
        }
        Parametro.guardar(CLAVE, "Citas de ejemplo creadas: " + creadas + " el " + agenda.ahora());
    }

    private LocalDate diaAtendidoAntesDe(Profesional p, LocalDate fecha) {
        LocalDate d = fecha;
        for (int i = 0; i < 7 && !p.getDias().contains(d.getDayOfWeek()); i++) {
            d = d.minusDays(1);
        }
        return d;
    }

    private LocalDateTime primerHorarioLibre(Profesional p, Usuario paciente) {
        // Se salta el dia de hoy para que la cita quede reprogramable (minimo 2 horas)
        LocalDate manana = agenda.ahora().toLocalDate().plusDays(1);
        for (Map.Entry<LocalDate, List<LocalTime>> e : agenda.disponibilidad(p, null).entrySet()) {
            if (e.getKey().isBefore(manana)) {
                continue;
            }
            List<LocalTime> horas = new ArrayList<>(e.getValue());
            for (LocalTime h : horas) {
                LocalDateTime inicio = e.getKey().atTime(h);
                if (!Cita.pacienteOcupado(paciente.id, inicio, null)) {
                    return inicio;
                }
            }
        }
        return null;
    }

    private void crear(Usuario paciente, Profesional p, LocalDateTime inicio, String estado) {
        Cita c = new Cita();
        c.idUsuario = paciente.id;
        c.idProfesional = p.id;
        c.especialidad = p.especialidad.nombre;
        c.medico = p.nombre;
        c.fechaInicio = inicio;
        c.fechaHora = inicio.format(FORMATO).toUpperCase(Locale.US);
        c.estado = estado;
        c.persist();
    }
}
