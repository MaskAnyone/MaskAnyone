import { RJSFSchema } from "@rjsf/utils";

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

export type HidingStrategy = {
    key: string, // @todo add exact values "blur" | "blackout" | "estimate"
    params: object
}

// videopart describes the part of the video that should be masked (e.g face, background, body...)
export type VideoMaskingParams ={
    [videoPart: string] : {
        hidingStrategy: HidingStrategy,
        maskingStrategy?: any // Not every video part can be masked (e.g background can only be hidden)
    }
}

export type RunParams = {
    videoMasking: VideoMaskingParams
    threeDModelCreation: any
    voiceMasking: any
}