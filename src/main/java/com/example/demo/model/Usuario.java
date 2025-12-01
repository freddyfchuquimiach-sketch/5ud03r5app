package com.example.demo.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Usuario {
	
	private String nombre;
    private String email;
    private String fecha; // nuevo campo

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getFecha() { 
    	return fecha; 
    }
    
    public void setFecha(String fecha) { 
    	this.fecha = fecha; 
    }
    
    @Override
    public String toString() {
        return "Usuario{" +
                "nombre='" + nombre + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
    
 // Método para formatear la fecha bonito
    public String getFechaFormateada() {
        if (fecha == null) return "";
        LocalDateTime dt = LocalDateTime.parse(fecha, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        return dt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
	
}
