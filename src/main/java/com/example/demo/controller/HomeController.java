package com.example.demo.controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

import com.example.demo.model.Usuario;

@Controller
public class HomeController {

	private List<Usuario> usuarios = new ArrayList<>();

    @GetMapping("/")
    public String index() {
        return "index";
    }

    @GetMapping("/usuarios")
    public String listarUsuarios(Model model) {
        model.addAttribute("usuarios", usuarios);
        return "usuarios";
    }

    @PostMapping("/agregar-usuario")
    public String agregarUsuario(String nombre, String email) {
        Usuario usuario = new Usuario();
        usuario.setNombre(nombre);
        usuario.setEmail(email);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        usuario.setFecha(LocalDateTime.now().format(formatter));
        usuarios.add(usuario);
        return "redirect:/usuarios";
    }
    
 // Solo para pruebas unitarias 
    public List<Usuario> getUsuarios() {
        return usuarios;
    }
	
}
