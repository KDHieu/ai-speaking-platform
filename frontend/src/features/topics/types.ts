export type PromptKind = 'MAIN' | 'CUE' | 'FOLLOW_UP';

export type VocabularyKind =
    | 'WORD'
    | 'COLLOCATION'
    | 'IDIOM'
    | 'PHRASE';

export interface PracticeModeResponse {
    code: string;
    preparationSeconds: number;
    speakingSeconds: number | null;
}

export interface TopicPromptResponse {
    kind: PromptKind;
    text: string;
    displayOrder: number;
}

export interface VocabularyResponse {
    expression: string;
    kind: VocabularyKind;
    meaningVi: string | null;
    exampleSentence: string | null;
}

export interface TopicResponse {
    id: string;
    slug: string;
    title: string;
    category: string;
    practiceMode: PracticeModeResponse;
    prompts: TopicPromptResponse[];
    vocabularySuggestions: VocabularyResponse[];
}
