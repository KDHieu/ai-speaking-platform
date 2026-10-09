
package com.aispeaking.backend.topic.controller;

import com.aispeaking.backend.topic.dto.response.TopicResponse;
import com.aispeaking.backend.topic.service.TopicService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/topics")
public class TopicController {

    private final TopicService topicService;

    public TopicController(TopicService topicService) {
        this.topicService = topicService;
    }

    // GET /api/v1/topics/random?mode=IELTS_PART2
    @GetMapping("/random")
    public ResponseEntity<TopicResponse> getRandomTopic(
            @RequestParam(defaultValue = "IELTS_PART2")
            String mode
    ) {
        TopicResponse response =
                topicService.getRandomTopic(mode);

        return ResponseEntity.ok(response);
    }

    // GET /api/v1/topics/{id}
    @GetMapping("/{id}")
    public ResponseEntity<TopicResponse> getTopicById(
            @PathVariable UUID id
    ) {
        TopicResponse response =
                topicService.getTopicById(id);

        return ResponseEntity.ok(response);
    }
}
