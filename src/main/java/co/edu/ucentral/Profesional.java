package co.edu.ucentral;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import com.fasterxml.jackson.annotation.JsonIgnore;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * HU006 - Profesional de la salud asociado a una especialidad, con su horario de atencion.
 */
@Entity
@Table(name = "profesional")
public class Profesional extends PanacheEntity {

    @Column(nullable = false)
    public String nombre;

    @Column(name = "registro_medico")
    public String registroMedico;

    public String correo;

    public String consultorio;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "especialidad_id")
    public Especialidad especialidad;

    public Boolean activo = Boolean.TRUE;

    /** Dias de atencion ISO separados por coma (1 = lunes ... 7 = domingo). */
    @Column(name = "dias_atencion", nullable = false)
    public String diasAtencion = "1,2,3,4,5";

    @Column(name = "hora_inicio", nullable = false)
    public LocalTime horaInicio = LocalTime.of(8, 0);

    @Column(name = "hora_fin", nullable = false)
    public LocalTime horaFin = LocalTime.of(12, 0);

    @Column(name = "duracion_minutos", nullable = false)
    public Integer duracionMinutos = 30;

    public static List<Profesional> listarActivosPorEspecialidad(Long especialidadId) {
        return list("especialidad.id = ?1 and activo = true order by nombre", especialidadId);
    }

    @JsonIgnore
    public Set<DayOfWeek> getDias() {
        return Arrays.stream(diasAtencion.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(s -> DayOfWeek.of(Integer.parseInt(s)))
                .collect(Collectors.toSet());
    }

    @JsonIgnore
    public boolean estaActivo() {
        return activo == null || activo;
    }
}
