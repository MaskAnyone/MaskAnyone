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
    params: {
        [paramterName: string]: any;
    }
}

// videopart describes the part of the video that should be masked (e.g face, background, body...)
export type VideoMaskingParams = {
    hidingTarget: "face" | "body" | "none"
    hidingStrategyTarget: Strategy
    hidingStrategyBG: Strategy
    maskingStrategy: Strategy
}

export type VoiceMaskingParams = {
    maskingStrategy: Strategy;
}

export type ThreeDModelCreationParams = {
    skeleton: boolean,
    skeletonParams: { [paramName: string]: any }
    blender: boolean,
    blenderParams: { [paramName: string]: any }
    blendshapes: boolean,
    blendshapesParams: { [paramName: string]: any }
}

export type RunParams = {
    videoMasking: VideoMaskingParams
    threeDModelCreation: ThreeDModelCreationParams
    voiceMasking: VoiceMaskingParams
}
