package com.example.demo.controller;

import com.example.demo.model.Usuario;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.ui.Model;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class HomeControllerTest {

    private HomeController controller;
    private Model model;

    @BeforeEach
    void setUp() {
        controller = new HomeController();
        model = mock(Model.class);
    }

    @Test
    void index_debeDevolverVistaIndex() {
        String vista = controller.index();
        assertEquals("index", vista);
    }

    @Test
    void listarUsuarios_sinUsuarios_debeDevolverVistaUsuariosYListaVacia() {
        String vista = controller.listarUsuarios(model);

        assertEquals("usuarios", vista);
        verify(model).addAttribute(eq("usuarios"), anyList());
    }

    @Test
    void agregarUsuario_debeAgregarUsuarioYRedirigir() {
        // Cuando
        String redirect = controller.agregarUsuario("Freddy", "freddy@example.com");

        // Entonces
        assertEquals("redirect:/usuarios", redirect);

        // Verificamos que realmente se agregó (usamos reflexión porque la lista es privada)
        List<Usuario> usuarios = controller.getUsuarios(); // añades este getter temporal
        assertEquals(1, usuarios.size());
        assertEquals("Freddy", usuarios.get(0).getNombre());
        assertEquals("freddy@example.com", usuarios.get(0).getEmail());
    }
}