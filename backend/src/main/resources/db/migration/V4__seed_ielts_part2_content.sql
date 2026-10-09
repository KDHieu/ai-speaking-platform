
-- ===========================================
-- V4: Seed IELTS Speaking Part 2 Content
-- ===========================================

-- 1. Practice Mode
INSERT INTO practice_modes (
    code,
    name,
    preparation_seconds,
    speaking_seconds
)
VALUES (
           'IELTS_PART2',
           'IELTS Speaking Part 2',
           60,
           120
       )
    ON CONFLICT (code) DO NOTHING;


-- 2. Topics
INSERT INTO topics (
    practice_mode_id,
    slug,
    title,
    category
)
SELECT
    pm.id,
    data.slug,
    data.title,
    data.category
FROM practice_modes pm
         CROSS JOIN (
    VALUES
        ('memorable-journey',
         'Describe a memorable journey', 'Travel'),

        ('skill-you-learned',
         'Describe a skill you learned', 'Education'),

        ('person-you-admire',
         'Describe a person you admire', 'People'),

        ('useful-mobile-app',
         'Describe a useful mobile application', 'Technology'),

        ('book-you-enjoyed',
         'Describe a book you enjoyed', 'Entertainment'),

        ('quiet-place',
         'Describe a quiet place you like', 'Places'),

        ('special-celebration',
         'Describe a special celebration', 'Events'),

        ('challenging-task',
         'Describe a challenging task you completed',
         'Experiences'),

        ('everyday-object',
         'Describe an object you use every day', 'Objects'),

        ('interesting-conversation',
         'Describe an interesting conversation',
         'Communication')
) AS data(slug, title, category)
WHERE pm.code = 'IELTS_PART2';


-- 3. Topic Prompts
WITH cards (
            slug,
            main_prompt,
            cue1,
            cue2,
            cue3,
            cue4
    ) AS (
    VALUES
        (
            'memorable-journey',
            'Describe a journey you remember well.',
            'Where you went',
            'Who you went with',
            'What happened during the journey',
            'Explain why it was memorable'
        ),
        (
            'skill-you-learned',
            'Describe a skill you have learned.',
            'What the skill is',
            'When you learned it',
            'How you learned it',
            'Explain why this skill is useful'
        ),
        (
            'person-you-admire',
            'Describe a person you admire.',
            'Who this person is',
            'How you know this person',
            'What qualities this person has',
            'Explain why you admire this person'
        ),
        (
            'useful-mobile-app',
            'Describe a mobile application you find useful.',
            'What the application is',
            'When you started using it',
            'How you use it',
            'Explain why it is useful to you'
        ),
        (
            'book-you-enjoyed',
            'Describe a book you enjoyed reading.',
            'What the book is',
            'When you read it',
            'What it is about',
            'Explain why you enjoyed it'
        ),
        (
            'quiet-place',
            'Describe a quiet place you like visiting.',
            'Where this place is',
            'When you usually go there',
            'What you do there',
            'Explain why you like this place'
        ),
        (
            'special-celebration',
            'Describe a special celebration you attended.',
            'What the celebration was',
            'When and where it took place',
            'Who attended it',
            'Explain why it was special'
        ),
        (
            'challenging-task',
            'Describe a challenging task you completed.',
            'What the task was',
            'Why it was challenging',
            'How you completed it',
            'Explain how you felt afterwards'
        ),
        (
            'everyday-object',
            'Describe an object you use every day.',
            'What the object is',
            'How you got it',
            'How you use it',
            'Explain why it is important to you'
        ),
        (
            'interesting-conversation',
            'Describe an interesting conversation you had.',
            'Who you spoke with',
            'When and where it happened',
            'What you talked about',
            'Explain why it was interesting'
        )
)
INSERT INTO topic_prompts (
    topic_id,
    prompt_kind,
    prompt_text,
    display_order
)
SELECT
    t.id,
    CASE
        WHEN p.ordinal = 1 THEN 'MAIN'
        ELSE 'CUE'
    END,
    p.prompt_text,
    p.ordinal::INTEGER
FROM cards c
JOIN topics t ON t.slug = c.slug
CROSS JOIN LATERAL unnest(
    ARRAY[
        c.main_prompt,
        c.cue1,
        c.cue2,
        c.cue3,
        c.cue4
    ]
) WITH ORDINALITY AS p(prompt_text, ordinal);


-- 4. Vocabulary Suggestions
INSERT INTO vocabulary_suggestions (
    topic_id,
    expression,
    kind,
    meaning_vi,
    example_sentence,
    display_order
)
SELECT
    t.id,
    v.expression,
    v.kind,
    v.meaning_vi,
    v.example_sentence,
    v.display_order
FROM (
         VALUES
             -- Travel
             ('memorable-journey',
              'breathtaking scenery', 'COLLOCATION',
              'Phong cảnh đẹp đến ngỡ ngàng',
              'We enjoyed the breathtaking scenery.', 1),
             ('memorable-journey',
              'step out of my comfort zone', 'PHRASE',
              'Bước ra khỏi vùng an toàn',
              'The trip helped me step out of my comfort zone.', 2),
             ('memorable-journey',
              'a once-in-a-lifetime experience', 'COLLOCATION',
              'Trải nghiệm có một không hai',
              'It was a once-in-a-lifetime experience.', 3),

             -- Education
             ('skill-you-learned',
              'a steep learning curve', 'COLLOCATION',
              'Quá trình học hỏi đầy thử thách',
              'Programming had a steep learning curve.', 1),
             ('skill-you-learned',
              'pick up a skill', 'PHRASE',
              'Học được một kỹ năng',
              'I wanted to pick up a new skill.', 2),
             ('skill-you-learned',
              'a sense of achievement', 'COLLOCATION',
              'Cảm giác thành tựu',
              'I felt a sense of achievement.', 3),

             -- People
             ('person-you-admire',
              'role model', 'PHRASE',
              'Hình mẫu để noi theo',
              'My teacher has always been a role model.', 1),
             ('person-you-admire',
              'perseverance', 'WORD',
              'Sự kiên trì',
              'I admire her perseverance.', 2),
             ('person-you-admire',
              'look up to someone', 'PHRASE',
              'Ngưỡng mộ ai đó',
              'I have always looked up to my father.', 3),

             -- Technology
             ('useful-mobile-app',
              'user-friendly interface', 'COLLOCATION',
              'Giao diện thân thiện với người dùng',
              'The app has a user-friendly interface.', 1),
             ('useful-mobile-app',
              'streamline daily tasks', 'COLLOCATION',
              'Đơn giản hóa công việc hằng ngày',
              'It helps me streamline daily tasks.', 2),
             ('useful-mobile-app',
              'stay on top of things', 'PHRASE',
              'Kiểm soát tốt công việc',
              'The app helps me stay on top of things.', 3),

             -- Entertainment
             ('book-you-enjoyed',
              'thought-provoking', 'WORD',
              'Gợi nhiều suy nghĩ',
              'It is a thought-provoking novel.', 1),
             ('book-you-enjoyed',
              'plot twist', 'PHRASE',
              'Tình tiết bất ngờ',
              'The story has an unexpected plot twist.', 2),
             ('book-you-enjoyed',
              'broaden my perspective', 'COLLOCATION',
              'Mở rộng góc nhìn',
              'The book helped broaden my perspective.', 3),

             -- Places
             ('quiet-place',
              'unwind after a long day', 'PHRASE',
              'Thư giãn sau một ngày dài',
              'I go there to unwind after a long day.', 1),
             ('quiet-place',
              'peaceful atmosphere', 'COLLOCATION',
              'Bầu không khí yên bình',
              'I love the peaceful atmosphere.', 2),
             ('quiet-place',
              'recharge my batteries', 'IDIOM',
              'Nạp lại năng lượng',
              'The park helps me recharge my batteries.', 3),

             -- Events
             ('special-celebration',
              'mark a special occasion', 'COLLOCATION',
              'Đánh dấu một dịp đặc biệt',
              'We gathered to mark a special occasion.', 1),
             ('special-celebration',
              'cherish the moment', 'PHRASE',
              'Trân trọng khoảnh khắc',
              'I wanted to cherish the moment.', 2),
             ('special-celebration',
              'a heartwarming gathering', 'COLLOCATION',
              'Buổi tụ họp ấm áp',
              'It was a heartwarming gathering.', 3),

             -- Experiences
             ('challenging-task',
              'tackle a challenge', 'COLLOCATION',
              'Đối mặt và giải quyết thử thách',
              'I was determined to tackle the challenge.', 1),
             ('challenging-task',
              'under pressure', 'PHRASE',
              'Trong tình trạng áp lực',
              'I had to work under pressure.', 2),
             ('challenging-task',
              'pay off in the end', 'PHRASE',
              'Cuối cùng mang lại kết quả tốt',
              'My hard work paid off in the end.', 3),

             -- Objects
             ('everyday-object',
              'indispensable', 'WORD',
              'Không thể thiếu',
              'My laptop is indispensable to my studies.', 1),
             ('everyday-object',
              'come in handy', 'PHRASE',
              'Tỏ ra hữu ích',
              'It often comes in handy.', 2),
             ('everyday-object',
              'durable', 'WORD',
              'Bền bỉ',
              'The device is durable and reliable.', 3),

             -- Communication
             ('interesting-conversation',
              'exchange perspectives', 'COLLOCATION',
              'Trao đổi góc nhìn',
              'We had a chance to exchange perspectives.', 1),
             ('interesting-conversation',
              'eye-opening discussion', 'COLLOCATION',
              'Cuộc thảo luận mở mang hiểu biết',
              'It was an eye-opening discussion.', 2),
             ('interesting-conversation',
              'strike up a conversation', 'PHRASE',
              'Bắt đầu một cuộc trò chuyện',
              'I struck up a conversation with a stranger.', 3)

     ) AS v(
            slug,
            expression,
            kind,
            meaning_vi,
            example_sentence,
            display_order
    )
         JOIN topics t ON t.slug = v.slug;
