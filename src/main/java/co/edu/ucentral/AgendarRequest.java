package co.edu.ucentral;

/**
 * HU008 / HU012 - Datos para agendar o reprogramar una cita.
 * fecha en formato yyyy-MM-dd y hora en formato HH:mm.
 */
public class AgendarRequest {
    public Long idUsuario;
    public Long idProfesional;
    public String fecha;
    public String hora;
}
