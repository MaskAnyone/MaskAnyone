
export interface ResultVideo {
    videoResultId: string;
    originalVideoId: string;
    jobId: string;
    createdAt: Date;
    jobInfo: any;
    videoResultExists: boolean;
    kinematicResultsExists: boolean;
    audioResultsExists: boolean;
    blendshapeResultsExists: boolean;
    extraFileResultsExists: boolean;
    videoInfo: any;
    name: string;
}
