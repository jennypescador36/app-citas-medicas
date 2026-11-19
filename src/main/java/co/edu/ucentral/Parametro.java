package co.edu.ucentral;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Parametros internos del sistema (por ejemplo, marcar que una carga de datos ya se ejecuto).
 */
@Entity
@Table(name = "parametro")
public class Parametro extends PanacheEntityBase {

    @Id
    public String clave;

    public String valor;

    public static boolean existe(String clave) {
        return findById(clave) != null;
    }

    public static void guardar(String clave, String valor) {
        Parametro p = findById(clave);
        if (p == null) {
            p = new Parametro();
            p.clave = clave;
        }
        p.valor = valor;
        p.persist();
    }
}
