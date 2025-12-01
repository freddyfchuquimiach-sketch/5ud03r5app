package com.example.demo.model;

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
	
}
