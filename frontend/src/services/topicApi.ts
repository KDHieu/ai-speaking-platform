import type { TopicResponse } from '../features/topics/types'

const API_BASE_URL = '/api/v1/topics'

export async function getRandomTopic(
    mode: string = 'IELTS_PART2',
    signal?: AbortSignal,
): Promise<TopicResponse> {
    const params = new URLSearchParams({ mode })

    const response = await fetch(
        `${API_BASE_URL}/random?${params.toString()}`,
        { signal },
    )

    if (!response.ok) {
        throw new Error(
            `Failed to fetch random topic: HTTP ${response.status}`,
        )
    }

    return (await response.json()) as TopicResponse
}

export async function getTopicById(
    id: string,
    signal?: AbortSignal,
): Promise<TopicResponse> {
    const response = await fetch(
        `${API_BASE_URL}/${encodeURIComponent(id)}`,
        { signal },
    )

    if (!response.ok) {
        throw new Error(
            `Failed to fetch topic: HTTP ${response.status}`,
        )
    }

    return (await response.json()) as TopicResponse
}
