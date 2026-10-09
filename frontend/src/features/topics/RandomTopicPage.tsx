import {
    useCallback,
    useEffect,
    useRef,
    useState,
} from 'react'
import {
    AlertCircle,
    Clock3,
    Mic2,
    RefreshCw,
    Shuffle,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
    Card,
    CardContent,
    CardHeader,
    CardTitle,
} from '@/components/ui/card'
import {
    Alert,
    AlertDescription,
    AlertTitle,
} from '@/components/ui/alert'
import { Skeleton } from '@/components/ui/skeleton'
import { getRandomTopic } from '@/services/topicApi'
import VocabularyPanel from './components/VocabularyPanel'
import type { TopicResponse } from './types'

function LoadingSkeleton() {
    return (
        <div
            className="grid gap-6 lg:grid-cols-[3fr_2fr]"
            role="status"
            aria-label="Loading topic"
        >
            <Card>
                <CardHeader className="space-y-3">
                    <Skeleton className="h-7 w-3/4" />
                    <Skeleton className="h-5 w-1/3" />
                </CardHeader>
                <CardContent className="space-y-4">
                    {Array.from({ length: 5 }).map((_, index) => (
                        <Skeleton key={index} className="h-5 w-full" />
                    ))}
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <Skeleton className="h-7 w-2/3" />
                </CardHeader>
                <CardContent className="space-y-4">
                    {Array.from({ length: 3 }).map((_, index) => (
                        <Skeleton key={index} className="h-20 w-full" />
                    ))}
                </CardContent>
            </Card>
        </div>
    )
}

export default function RandomTopicPage() {
    const [topic, setTopic] =
        useState<TopicResponse | null>(null)

    const [isLoading, setIsLoading] = useState(true)
    const [error, setError] = useState<string | null>(null)

    const requestRef = useRef<AbortController | null>(null)

    const loadRandomTopic = useCallback(async () => {
        requestRef.current?.abort()

        const controller = new AbortController()
        requestRef.current = controller

        setIsLoading(true)
        setError(null)

        try {
            const data = await getRandomTopic(
                'IELTS_PART2',
                controller.signal,
            )

            if (!controller.signal.aborted) {
                setTopic(data)
            }
        } catch (err) {
            if (controller.signal.aborted) return

            setError(
                err instanceof Error
                    ? err.message
                    : 'An unexpected error occurred.',
            )
        } finally {
            if (!controller.signal.aborted) {
                setIsLoading(false)
            }
        }
    }, [])

    useEffect(() => {
        void loadRandomTopic()

        return () => {
            requestRef.current?.abort()
        }
    }, [loadRandomTopic])

    const mainPrompt = topic?.prompts.find(
        (prompt) => prompt.kind === 'MAIN',
    )

    const cuePrompts = topic?.prompts.filter(
        (prompt) => prompt.kind === 'CUE',
    ) ?? []

    return (
        <main className="min-h-screen bg-background text-foreground">
            <div className="mx-auto max-w-6xl px-4 py-10 sm:px-6">
                <header className="mb-8 flex flex-col gap-5 sm:flex-row sm:items-end sm:justify-between">
                    <div className="space-y-3">
                        <Badge variant="outline">
                            IELTS Speaking · Part 2
                        </Badge>

                        <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">
                            Speaking Practice
                        </h1>

                        <p className="text-muted-foreground">
                            Pick a topic, explore useful vocabulary,
                            and prepare to speak.
                        </p>
                    </div>

                    <Button
                        type="button"
                        onClick={() => void loadRandomTopic()}
                        disabled={isLoading}
                    >
                        <Shuffle className="mr-2 size-4" />
                        Roll Another Topic
                    </Button>
                </header>

                {isLoading && <LoadingSkeleton />}

                {!isLoading && error && (
                    <div className="space-y-4">
                        <Alert variant="destructive">
                            <AlertCircle className="size-4" />
                            <AlertTitle>
                                Failed to load topic
                            </AlertTitle>
                            <AlertDescription>
                                {error}
                            </AlertDescription>
                        </Alert>

                        <Button
                            variant="outline"
                            onClick={() => void loadRandomTopic()}
                        >
                            <RefreshCw className="mr-2 size-4" />
                            Try Again
                        </Button>
                    </div>
                )}

                {!isLoading && !error && topic && (
                    <div className="grid items-start gap-6 lg:grid-cols-[3fr_2fr]">
                        <Card>
                            <CardHeader className="space-y-3">
                                <Badge
                                    variant="secondary"
                                    className="w-fit"
                                >
                                    {topic.category}
                                </Badge>

                                <CardTitle className="text-2xl leading-snug">
                                    {topic.title}
                                </CardTitle>

                                <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
                  <span className="flex items-center gap-2">
                    <Clock3 className="size-4" />
                      {topic.practiceMode.preparationSeconds}s preparation
                  </span>

                                    <span className="flex items-center gap-2">
                    <Mic2 className="size-4" />
                                        {topic.practiceMode.speakingSeconds === null
                                            ? 'No time limit'
                                            : `${topic.practiceMode.speakingSeconds}s speaking`}
                  </span>
                                </div>
                            </CardHeader>

                            <CardContent className="space-y-6">
                                <div className="rounded-lg bg-muted p-5">
                                    <p className="text-lg font-medium">
                                        {mainPrompt?.text ?? topic.title}
                                    </p>
                                </div>

                                <div>
                                    <h2 className="mb-3 font-semibold">
                                        You should say:
                                    </h2>

                                    <ul className="list-disc space-y-3 pl-6 text-sm leading-relaxed">
                                        {cuePrompts.map((prompt) => (
                                            <li key={prompt.displayOrder}>
                                                {prompt.text}
                                            </li>
                                        ))}
                                    </ul>
                                </div>

                                <div className="rounded-lg border border-dashed p-4">
                                    <p className="text-sm text-muted-foreground">
                                        Preparation timer and recording
                                        will be available in the next sprints.
                                    </p>
                                </div>
                            </CardContent>
                        </Card>

                        <VocabularyPanel
                            key={topic.id}
                            vocabulary={topic.vocabularySuggestions}
                        />
                    </div>
                )}
            </div>
        </main>
    )
}
