package co.edu.ucentral;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Calcula los horarios libres de un profesional (HU006, HU008, HU012).
 * Un horario esta libre si cae dentro del horario de atencion, es futuro
 * y no existe una cita PROGRAMADA del profesional a esa misma hora.
 */
@ApplicationScoped
public class AgendaService {

    /** Zona horaria del centro medico (Render corre en UTC). */
    public static final ZoneId ZONA = ZoneId.of("America/Bogota");

    /** Cuantos dias hacia adelante se ofrecen para agendar. */
    public static final int DIAS_AGENDA = 14;

    public LocalDateTime ahora() {
        return LocalDateTime.now(ZONA);
    }

    /** Todos los horarios que el profesional atiende en esa fecha (sin mirar las citas). */
    public List<LocalTime> horariosDelDia(Profesional p, LocalDate fecha) {
        List<LocalTime> horarios = new ArrayList<>();
        if (!p.getDias().contains(fecha.getDayOfWeek())) {
            return horarios;
        }
        LocalTime hora = p.horaInicio;
        while (!hora.plusMinutes(p.duracionMinutos).isAfter(p.horaFin)) {
            horarios.add(hora);
            hora = hora.plusMinutes(p.duracionMinutos);
        }
        return horarios;
    }

    /** Horarios libres de un dia. excluirCitaId permite ignorar la cita que se esta reprogramando. */
    public List<LocalTime> horariosLibres(Profesional p, LocalDate fecha, Long excluirCitaId) {
        LocalDateTime inicioDia = fecha.atStartOfDay();
        Set<LocalDateTime> ocupados = Cita.programadasDelProfesional(p.id, inicioDia, inicioDia.plusDays(1))
                .stream()
                .filter(c -> excluirCitaId == null || !c.id.equals(excluirCitaId))
                .map(c -> c.fechaInicio)
                .collect(Collectors.toSet());
        LocalDateTime ahora = ahora();
        return horariosDelDia(p, fecha).stream()
                .filter(h -> fecha.atTime(h).isAfter(ahora))
                .filter(h -> !ocupados.contains(fecha.atTime(h)))
                .collect(Collectors.toList());
    }

    /** Fechas de los proximos dias que tienen al menos un horario libre, con sus horas. */
    public Map<LocalDate, List<LocalTime>> disponibilidad(Profesional p, Long excluirCitaId) {
        Map<LocalDate, List<LocalTime>> resultado = new LinkedHashMap<>();
        LocalDate hoy = ahora().toLocalDate();
        for (int i = 0; i < DIAS_AGENDA; i++) {
            LocalDate fecha = hoy.plusDays(i);
            List<LocalTime> libres = horariosLibres(p, fecha, excluirCitaId);
            if (!libres.isEmpty()) {
                resultado.put(fecha, libres);
            }
        }
        return resultado;
    }

    /** Verifica que el horario exista en la agenda del profesional, sea futuro y siga libre. */
    public String validarHorario(Profesional p, LocalDateTime inicio, Long excluirCitaId) {
        if (!inicio.isAfter(ahora())) {
            return "La fecha y hora seleccionadas ya pasaron";
        }
        if (inicio.toLocalDate().isAfter(ahora().toLocalDate().plusDays(DIAS_AGENDA - 1L))) {
            return "Solo se puede agendar dentro de los proximos " + DIAS_AGENDA + " dias";
        }
        if (!horariosDelDia(p, inicio.toLocalDate()).contains(inicio.toLocalTime())) {
            return "El profesional no atiende en ese horario";
        }
        if (Cita.horarioOcupado(p.id, inicio, excluirCitaId)) {
            return "El horario seleccionado ya no esta disponible";
        }
        return null;
    }
}
