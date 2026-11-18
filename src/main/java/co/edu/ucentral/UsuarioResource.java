package co.edu.ucentral;

import java.util.List;
import java.util.Map;

import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/usuarios")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UsuarioResource {

    private static final java.util.logging.Logger LOGGER =
            java.util.logging.Logger.getLogger(UsuarioResource.class.getName());

    @GET
    public List<Usuario> listarTodos() {
        return Usuario.listAll();
    }

    @POST
    @Transactional
    public Response crearUsuarioBase(Usuario usuario) {
        return procesarRegistro(usuario);
    }

    @POST
    @Path("/registro")
    @Transactional
    public Response registrarUsuario(Usuario usuario) {
        return procesarRegistro(usuario);
    }

    private static final java.util.regex.Pattern EMAIL =
            java.util.regex.Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    /**
     * HU002 - Inicio de sesion con correo y contrasena.
     * 200: datos del usuario (sin contrasena) con su tipo/rol.
     * 400: datos incompletos o correo invalido. 401: credenciales incorrectas. 403: cuenta inactiva.
     */
    @POST
    @Path("/login")
    public Response login(LoginRequest login) {
        if (login == null || login.correo == null || login.correo.isBlank()
                || login.contrasena == null || login.contrasena.isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("mensaje", "Debe ingresar correo y contrasena"))
                    .build();
        }
        if (!EMAIL.matcher(login.correo.trim()).matches()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("mensaje", "El correo no tiene un formato valido"))
                    .build();
        }

        Usuario usuario = Usuario.findByCorreo(login.correo);
        if (usuario == null || !login.contrasena.equals(usuario.contrasena)) {
            return Response.status(Response.Status.UNAUTHORIZED)
                    .entity(Map.of("mensaje", "Correo o contrasena incorrectos"))
                    .build();
        }
        if (!usuario.estaActivo()) {
            return Response.status(Response.Status.FORBIDDEN)
                    .entity(Map.of("mensaje", "La cuenta se encuentra inactiva"))
                    .build();
        }
        return Response.ok(usuario).build();
    }

    private Response procesarRegistro(Usuario usuario) {
        try {
            if (usuario == null || usuario.correo == null || usuario.documento == null || usuario.nombre == null || usuario.contrasena == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("mensaje", "Faltan campos obligatorios"))
                        .build();
            }

            usuario.correo = usuario.correo.trim().toLowerCase();
            if (!EMAIL.matcher(usuario.correo).matches()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("mensaje", "El correo no tiene un formato valido"))
                        .build();
            }
            if (usuario.contrasena.length() < 6) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("mensaje", "La contrasena debe tener al menos 6 caracteres"))
                        .build();
            }

            if (Usuario.findByCorreo(usuario.correo) != null) {
                return Response.status(Response.Status.CONFLICT)
                        .entity(Map.of("mensaje", "El correo ya se encuentra registrado"))
                        .build();
            }

            if (Usuario.find("documento", usuario.documento).firstResult() != null) {
                return Response.status(Response.Status.CONFLICT)
                        .entity(Map.of("mensaje", "El documento ya se encuentra registrado"))
                        .build();
            }

            if (usuario.tipoUsuario == null || usuario.tipoUsuario.isBlank()) {
                usuario.tipoUsuario = "PACIENTE";
            }
            usuario.activo = Boolean.TRUE;

            usuario.persist();
            return Response.status(Response.Status.CREATED).entity(usuario).build();

        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error interno al guardar usuario", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("mensaje", "Error interno al guardar en BD: " + e.getMessage()))
                    .build();
        }
    }
}