
export interface Worker {
    id: string;
    jobId?: string;
    lastActivity: Date;
    type: string;
}
