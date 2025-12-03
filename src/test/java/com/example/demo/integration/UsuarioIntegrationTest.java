package com.example.demo.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import static org.assertj.core.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UsuarioIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void paginaPrincipalDebeCargarse() {
        String body = restTemplate.getForObject("http://localhost:" + port + "/", String.class);
        assertThat(body).contains("PROYECTO FINAL CURSO DEVOPS");
    }

    @Test
    void listaUsuariosVaciaAlInicio() {
        String body = restTemplate.getForObject("http://localhost:" + port + "/usuarios", String.class);
        assertThat(body).contains("No hay usuarios registrados");
    }

    @Test
    void agregarUsuarioYVerloEnLista() {
        // POST con datos del formulario
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        map.add("nombre", "Carlos");
        map.add("email", "carlos@test.com");
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(map, headers);

        restTemplate.postForEntity("http://localhost:" + port + "/agregar-usuario", request, String.class);

        String lista = restTemplate.getForObject("http://localhost:" + port + "/usuarios", String.class);
        assertThat(lista)
                .contains("Carlos")
                .contains("carlos@test.com");
    }
}