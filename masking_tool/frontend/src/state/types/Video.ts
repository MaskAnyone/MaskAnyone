
export interface Video {
    id: string;
    name: string;
    status: 'valid';
    videoInfo: {
        fps: number;
        codec: 'avc1'|'mp4v'|string;
        duration: number;
        frameCount: number;
        frameWidth: number;
        frameHeight: number;
    };
}