package co.edu.ucentral;

import java.util.List;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

/**
 * HU006 - Especialidad medica ofrecida por el centro.
 */
@Entity
@Table(name = "especialidad")
public class Especialidad extends PanacheEntity {

    @Column(nullable = false, unique = true)
    public String nombre;

    @Column(length = 500)
    public String descripcion;

    public Boolean activa = Boolean.TRUE;

    public static List<Especialidad> listarActivas() {
        return list("activa = true order by nombre");
    }
}
