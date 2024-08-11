
export interface Job {
    id: string;
    videoId: string;
    type: string;
    status: 'open'|'running'|'finished'|'failed';
    data: object;
    createdAt: Date;
    startedAt?: Date;
    finishedAt?: Date;
    progress: number;
}

export type JobType = 'basic_masking'|'sam2_masking';
