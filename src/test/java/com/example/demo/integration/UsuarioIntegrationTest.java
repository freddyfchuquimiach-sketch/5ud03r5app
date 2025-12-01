package com.example.demo.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UsuarioIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void debeMostrarPaginaPrincipal() {
        ResponseEntity<String> response = restTemplate.getForEntity("http://localhost:" + port + "/", String.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).contains("Proyecto de Pruebas con Git");
    }

    @Test
    void debeMostrarListaUsuariosVaciaInicialmente() {
        ResponseEntity<String> response = restTemplate.getForEntity("http://localhost:" + port + "/usuarios", String.class);
        assertThat(response.getBody()).contains("No hay usuarios registrados");
    }

    @Test
    void debeAgregarUsuarioYMostrarloEnLaLista() {
        // Agregar usuario mediante POST
        restTemplate.postForEntity("http://localhost:" + port + "/agregar-usuario",
                "nombre=Ana&email=ana@test.com", String.class);

        // Ver que ahora aparece en la lista
        ResponseEntity<String> response = restTemplate.getForEntity("http://localhost:" + port + "/usuarios", String.class);
        assertThat(response.getBody())
                .contains("Ana")
                .contains("ana@test.com");
    }
}
