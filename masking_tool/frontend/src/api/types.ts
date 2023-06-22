
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
