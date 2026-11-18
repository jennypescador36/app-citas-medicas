package co.edu.ucentral;

import java.time.LocalDateTime;
import java.util.List;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "citas")
public class Cita extends PanacheEntity {

    @Column(name = "id_usuario", nullable = false)
    public Long idUsuario;

    @Column(nullable = false)
    public String especialidad;

    @Column(nullable = false)
    public String medico;

    @Column(name = "fecha_hora", nullable = false)
    public String fechaHora;

    @Column(nullable = false)
    public String estado;

    // HU006/HU008: profesional que atiende y fecha-hora exacta para controlar la disponibilidad
    @Column(name = "id_profesional")
    public Long idProfesional;

    @Column(name = "fecha_inicio")
    public LocalDateTime fechaInicio;

    /** Indica si el profesional ya tiene una cita programada en esa fecha y hora. */
    public static boolean horarioOcupado(Long idProfesional, LocalDateTime inicio, Long excluirCitaId) {
        return count("idProfesional = ?1 and fechaInicio = ?2 and estado = 'PROGRAMADA' and id <> ?3",
                idProfesional, inicio, excluirCitaId == null ? -1L : excluirCitaId) > 0;
    }

    public static List<Cita> programadasDelProfesional(Long idProfesional, LocalDateTime desde, LocalDateTime hasta) {
        return list("idProfesional = ?1 and estado = 'PROGRAMADA' and fechaInicio >= ?2 and fechaInicio < ?3",
                idProfesional, desde, hasta);
    }

    public static List<Cita> listByUsuario(Long idUsuario) {
        return list("idUsuario", idUsuario);
    }
}