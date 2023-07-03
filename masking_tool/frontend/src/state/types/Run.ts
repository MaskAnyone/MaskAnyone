export type Preset = {
    detailImagePaths?: string[]
    detailText?: string,
    name: string,
    previewImagePath?: string,
    runParams: RunParams
}

export interface Run {
    id: string;
    duration: number
    params: string
    status: 'running' | 'success' | 'failed';
    videoName: string;
}

export type Strategy = {
    key: string, // @todo add exact values "blur" | "blackout" | "estimate"
    params: object
}

// videopart describes the part of the video that should be masked (e.g face, background, body...)
export type VideoMaskingParams = {
    [videoPart: string] : {
        hidingStrategy: Strategy,
        maskingStrategy?: Strategy // Not every video part can be masked (e.g background can only be hidden)
    }
}

export type ThreeDModelCreationParams = {
    skeleton: boolean,
    skeletonParams: {[paramName: string]: any}
    blender: boolean,
    blenderParams: {[paramName: string]: any}
    blendshapes: boolean,
    blendshapesParams: {[paramName: string]: any}
}

export type RunParams = {
    videoMasking: VideoMaskingParams
    threeDModelCreation: ThreeDModelCreationParams
    voiceMasking: any
}