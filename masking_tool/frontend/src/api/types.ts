
export interface ApiFetchVideosResponse {
    videos: {
        id: string;
        name: string;
        status: 'valid';
        video_info: {
            fps: number;
            codec: 'avc1'|'mp4v'|string;
            duration: number;
            frame_count: number;
            frame_width: number;
            frame_height: number;
        };
    }[];
}

export interface ApiFetchResultVideosResponse {
    result_videos: {
        id: string;
        video_id: string;
        job_id: string;
        name: string;
        video_info: any; //@todo
        created_at: string;
    }[];
}

export interface ApiFetchDownloadableResultFilesResponse {
    files: {
        id: string;
        title: string;
        url: string;
    }[];
}

export interface ApiFetchJobsResponse {
    jobs: {
        id: string;
        video_id: string;
        type: string;
        status: 'open'|'running'|'finished'|'failed';
        data: object;
        created_at: string;
        started_at: string|null;
        finished_at: string|null;
        progress: number;
    }[];
}

export interface ApiFetchWorkersResponse {
    workers: {
        id: string;
        job_id?: string;
        last_activity: string;
    }[];
}
