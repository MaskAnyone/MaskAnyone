export interface Run {
    id: string;
    videoName: string;
    status: 'running' | 'success' | 'failed';
    params: string
    duration: number
}