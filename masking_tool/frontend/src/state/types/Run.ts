export interface Run {
    id: string;
    videoName: string;
    status: 'running' | 'success' | 'failed';
    params: string
    duration: number
}

export type RunParams = {

}

export type Preset = {
    name: string,
    previewImagePath?: string,
    detailText?: string,
    detailImagePaths?: string[]
}