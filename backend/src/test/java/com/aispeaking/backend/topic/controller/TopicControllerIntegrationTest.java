
package com.aispeaking.backend.topic.controller;

import com.aispeaking.backend.topic.dto.response.TopicResponse;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClient;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
class TopicControllerIntegrationTest {

    @Value("${local.server.port}")
    private int port;

    private RestClient restClient;

    @BeforeEach
    void setUp() {
        restClient = RestClient.builder()
                .baseUrl("http://localhost:" + port)
                .build();
    }

    @Test
    void shouldReturnRandomIeltsTopic() {

        ResponseEntity<TopicResponse> response =
                restClient.get()
                        .uri("/api/v1/topics/random?mode=IELTS_PART2")
                        .retrieve()
                        .toEntity(TopicResponse.class);

        assertEquals(200, response.getStatusCode().value());

        TopicResponse topic = response.getBody();

        assertNotNull(topic);
        assertNotNull(topic.id());
        assertNotNull(topic.title());

        assertEquals(
                "IELTS_PART2",
                topic.practiceMode().code()
        );

        assertEquals(60,
                topic.practiceMode().preparationSeconds());

        assertEquals(120,
                topic.practiceMode().speakingSeconds());

        assertEquals(5, topic.prompts().size());
        assertEquals(3, topic.vocabularySuggestions().size());
    }

    @Test
    void shouldReturnTopicById() {

        TopicResponse randomTopic = restClient.get()
                .uri("/api/v1/topics/random")
                .retrieve()
                .body(TopicResponse.class);

        assertNotNull(randomTopic);

        TopicResponse foundTopic = restClient.get()
                .uri(
                        "/api/v1/topics/{id}",
                        randomTopic.id()
                )
                .retrieve()
                .body(TopicResponse.class);

        assertNotNull(foundTopic);
        assertEquals(randomTopic.id(), foundTopic.id());
        assertEquals(randomTopic.slug(), foundTopic.slug());

        assertEquals(5, foundTopic.prompts().size());
        assertEquals(
                3,
                foundTopic.vocabularySuggestions().size()
        );
    }

    @Test
    void shouldReturn404ForUnknownMode() {

        HttpClientErrorException exception =
                assertThrows(
                        HttpClientErrorException.class,
                        () -> restClient.get()
                                .uri("/api/v1/topics/random?mode=INVALID")
                                .retrieve()
                                .toBodilessEntity()
                );

        assertEquals(
                404,
                exception.getStatusCode().value()
        );

        assertTrue(
                exception.getResponseBodyAsString()
                        .contains("Practice mode not found")
        );
    }

    @Test
    void shouldReturn400ForInvalidUuid() {

        HttpClientErrorException exception =
                assertThrows(
                        HttpClientErrorException.class,
                        () -> restClient.get()
                                .uri("/api/v1/topics/not-a-uuid")
                                .retrieve()
                                .toBodilessEntity()
                );

        assertEquals(
                400,
                exception.getStatusCode().value()
        );
    }
}
