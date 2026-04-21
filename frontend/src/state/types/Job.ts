
export interface Job {
    id: string;
    videoId: string;
    type: string;
    status: 'open'|'running'|'finished'|'failed'|'cancelled';
    data: object;
    createdAt: Date;
    startedAt?: Date;
    finishedAt?: Date;
    progress: number;
    phase?: string | null;
}

export type JobType = 'basic_masking'|'sam2_masking';
