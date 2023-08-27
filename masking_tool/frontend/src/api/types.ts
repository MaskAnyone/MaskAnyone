
export interface ApiFetchVideosResponse {
    videos: {
        id: string;
        name: string;
        status: 'valid';
        video_info: {
            fps: number;
            codec: 'avc1' | 'mp4v' | string;
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

export interface ApiFetchAllResultsResponse {
    results: {
        video_result_id: string;
        original_video_id: string;
        job_id: string;
        created_at: string;
        job_info: any;
        video_result_exists: boolean;
        kinematic_results_exists: boolean;
        audio_results_exists: boolean;
        blendshape_results_exists: boolean;
        extra_file_results_exists: boolean;
        video_info: any;
        name: string
    }[]
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
        status: 'open' | 'running' | 'finished' | 'failed';
        data: object;
        created_at: string;
        started_at: string | null;
        finished_at: string | null;
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

export interface ApiFetchPresetsResponse {
    presets: {
        id: string;
        name: string;
        description: string;
        data: object;
    }[];
}
