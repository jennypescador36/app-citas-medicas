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

    private Response procesarRegistro(Usuario usuario) {
        try {
            if (usuario == null || usuario.correo == null || usuario.documento == null || usuario.nombre == null || usuario.contrasena == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("mensaje", "Faltan campos obligatorios"))
                        .build();
            }

            if (Usuario.find("correo", usuario.correo).firstResult() != null) {
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