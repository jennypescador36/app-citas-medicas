package co.edu.ucentral;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;

/**
 * Usuario
 */
@Entity
@Table(name = "usuario")
@JsonIgnoreProperties(ignoreUnknown = true)
public class Usuario extends PanacheEntityBase {

@Id
@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "usuario_seq")
@SequenceGenerator(name = "usuario_seq", sequenceName = "usuario_seq", allocationSize = 50)
public Long id;

    @Column(nullable = false, unique = true)
    public String documento;

    @Column(nullable = false)
    public String nombre;

    @Column(nullable = false, unique = true)
    public String correo;

    // Solo se recibe en el registro/login; nunca se devuelve en las respuestas JSON
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(nullable = false)
    public String contrasena;

    @Column(name = "tipo_usuario")
    public String tipoUsuario;

    // HU002: la cuenta debe estar activa para iniciar sesion (null = activa, para registros anteriores)
    public Boolean activo = Boolean.TRUE;

    public boolean estaActivo() {
        return activo == null || activo;
    }

    public static Usuario findByCorreo(String correo) {
        return find("lower(correo) = ?1", correo.trim().toLowerCase()).firstResult();
    }
}
