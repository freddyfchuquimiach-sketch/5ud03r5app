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
        assertEquals("index", controller.index());
    }

    @Test
    void listarUsuarios_debeAgregarAtributoAlModelo() {
        controller.listarUsuarios(model);
        verify(model).addAttribute(eq("usuarios"), anyList());
    }

    @Test
    void agregarUsuario_debeGuardarUsuarioYRedirigir() {
        controller.agregarUsuario("María", "maria@test.com");

        List<Usuario> usuarios = controller.getUsuariosForTest();
        assertEquals(1, usuarios.size());
        assertEquals("María", usuarios.get(0).getNombre());
        assertEquals("maria@test.com", usuarios.get(0).getEmail());
    }
}