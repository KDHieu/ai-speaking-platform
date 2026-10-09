import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import {
    Tabs,
    TabsContent,
    TabsList,
    TabsTrigger,
} from '@/components/ui/tabs'
import { BookOpen } from 'lucide-react'
import type { VocabularyResponse } from '../types'

interface VocabularyPanelProps {
    vocabulary: VocabularyResponse[]
}

function VocabularyList({
                            items,
                        }: {
    items: VocabularyResponse[]
}) {
    if (items.length === 0) {
        return (
            <p className="text-sm text-muted-foreground">
                No vocabulary suggestions available.
            </p>
        )
    }

    return (
        <div className="space-y-3">
            {items.map((item, index) => (
                <div
                    key={`${item.expression}-${index}`}
                    className="rounded-lg border p-4"
                >
                    <div className="mb-2 flex flex-wrap items-center gap-2">
                        <h3 className="font-semibold">
                            {item.expression}
                        </h3>
                        <Badge variant="secondary">
                            {item.kind}
                        </Badge>
                    </div>

                    {item.meaningVi && (
                        <p className="text-sm text-muted-foreground">
                            {item.meaningVi}
                        </p>
                    )}

                    {item.exampleSentence && (
                        <p className="mt-3 text-sm italic">
                            "{item.exampleSentence}"
                        </p>
                    )}
                </div>
            ))}
        </div>
    )
}

export default function VocabularyPanel({
                                            vocabulary,
                                        }: VocabularyPanelProps) {
    const expressions = vocabulary.filter(
        (item) =>
            item.kind === 'COLLOCATION' ||
            item.kind === 'IDIOM' ||
            item.kind === 'PHRASE',
    )

    return (
        <Card className="h-full">
            <CardHeader>
                <div className="flex items-center gap-2">
                    <BookOpen className="size-5" />
                    <CardTitle>
                        Vocabulary Suggestions
                    </CardTitle>
                </div>
                <CardDescription>
                    Useful vocabulary and expressions for your answer.
                </CardDescription>
            </CardHeader>

            <CardContent>
                <Tabs defaultValue="all">
                    <TabsList className="mb-4 grid w-full grid-cols-2">
                        <TabsTrigger value="all">
                            All
                        </TabsTrigger>
                        <TabsTrigger value="expressions">
                            Expressions
                        </TabsTrigger>
                    </TabsList>

                    <TabsContent value="all">
                        <VocabularyList items={vocabulary} />
                    </TabsContent>

                    <TabsContent value="expressions">
                        <VocabularyList items={expressions} />
                    </TabsContent>
                </Tabs>
            </CardContent>
        </Card>
    )
}
