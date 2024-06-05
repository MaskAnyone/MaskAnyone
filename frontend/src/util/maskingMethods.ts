import { HidingMethods, MaskingMethods } from "../state/types/RunParamRendering";
import {
    faceswapFormSchema,
    blackoutFormSchemaBG,
    blackoutFormSchemaSubject,
    blackoutFormSchemaSubjectUI,
    blenderMocapFormSchema,
    blurFormSchemaBG,
    blurFormSchemaSubject,
    blurFormSchemaSubjectUI,
    faceMeshFormSchema,
    inpaintFormSchemaSubject,
    inpaintFormSchemaSubjectUI,
    rvcSchema,
    skeletonFormSchema,
    contourFormSchemaSubject, contourFormSchemaSubjectUI
} from "./formSchemas";

export const maskingMethods: MaskingMethods = {
    blurring: {
        name: "Blurring",
        description: "Displays a basic skeleton containing landmarks for the head, torso, arms and legs",
        imagePath: '/images/masking_strategy/skeleton.jpg',
        parameterSchema: skeletonFormSchema,
        defaultValues: {
            maskingModel: "mediapipe",
            numPoses: 1,
            confidence: 0.5,
            timeseries: false
        },
        backendFormat: {
            "body": "skeleton",
            "face": "skeleton"
        }
    },
    pixelation: {
        name: "Pixelation",
        description: "Displays a basic skeleton containing landmarks for the head, torso, arms and legs",
        imagePath: '/images/masking_strategy/skeleton.jpg',
        parameterSchema: skeletonFormSchema,
        defaultValues: {
            maskingModel: "mediapipe",
            numPoses: 1,
            confidence: 0.5,
            timeseries: false
        },
        backendFormat: {
            "body": "skeleton",
            "face": "skeleton"
        }
    },
    blackout: {
        name: "Blackout",
        description: "Displays a basic skeleton containing landmarks for the head, torso, arms and legs",
        imagePath: '/images/masking_strategy/skeleton.jpg',
        parameterSchema: skeletonFormSchema,
        defaultValues: {
            maskingModel: "mediapipe",
            numPoses: 1,
            confidence: 0.5,
            timeseries: false
        },
        backendFormat: {
            "body": "skeleton",
            "face": "skeleton"
        }
    },
    contours: {
        name: "Contours",
        description: "Displays a basic skeleton containing landmarks for the head, torso, arms and legs",
        imagePath: '/images/masking_strategy/skeleton.jpg',
        parameterSchema: skeletonFormSchema,
        defaultValues: {
            maskingModel: "mediapipe",
            numPoses: 1,
            confidence: 0.5,
            timeseries: false
        },
        backendFormat: {
            "body": "skeleton",
            "face": "skeleton"
        }
    }
}

export const hidingMethods: HidingMethods = {
    face: {
        none: {
            name: "None",
            description: "Does not hide the subject in the video",
            imagePath: '',
        },
        blur: {
            name: "Blur",
            description: "Gaussian Blurring",
            imagePath: '',
            parameterSchema: blurFormSchemaSubject,
            uiSchema: blurFormSchemaSubjectUI,
            defaultValues: {
                subjectDetection: "boundingbox",
                detectionModel: "yolo",
                detectionParams: {
                    numPoses: 1,
                    confidence: 0.5
                },
                hidingParams: {
                    kernelSize: 23,
                    extraPixels: 0
                }
            }
        },
        blackout: {
            name: "Blackout",
            description: "Hiding the subject with the selected color",
            imagePath: '',
            parameterSchema: blackoutFormSchemaSubject,
            uiSchema: blackoutFormSchemaSubjectUI,
            defaultValues: {
                subjectDetection: "boundingbox",
                detectionModel: "yolo",
                detectionParams: {
                    numPoses: 1,
                    confidence: 0.5
                },
                hidingParams: {
                    color: 0,
                    extraPixels: 0
                }
            }
        },
    },
    body: {
        none: {
            name: "None",
            description: "Does not hide the subject in the video",
            imagePath: '',
        },
        blur: {
            name: "Blur",
            description: "Gaussian Blurring",
            imagePath: '',
            parameterSchema: blurFormSchemaSubject,
            uiSchema: blurFormSchemaSubjectUI,
            defaultValues: {
                subjectDetection: "silhouette",
                detectionModel: "mediapipe",
                detectionParams: {
                    numPoses: 1,
                    confidence: 0.5
                },
                hidingParams: {
                    kernelSize: 23,
                    extraPixels: 0
                }
            }
        },
        blackout: {
            name: "Blackout",
            description: "Hiding the subject with the selected color",
            imagePath: '',
            parameterSchema: blackoutFormSchemaSubject,
            uiSchema: blackoutFormSchemaSubjectUI,
            defaultValues: {
                subjectDetection: "silhouette",
                detectionModel: "mediapipe",
                detectionParams: {
                    numPoses: 1,
                    confidence: 0.5
                },
                hidingParams: {
                    color: 0,
                    extraPixels: 0
                }
            }
        },
        contour: {
            name: "Contours (Edge Detection)",
            description: "Hide the subject by only preserving their contours",
            imagePath: '',
            parameterSchema: contourFormSchemaSubject,
            uiSchema: contourFormSchemaSubjectUI,
            defaultValues: {
                subjectDetection: "silhouette",
                detectionModel: "mediapipe",
                detectionParams: {
                    numPoses: 1,
                    confidence: 0.5
                },
                hidingParams: {
                    level: 3,
                }
            }
        },
        inpaint: {
            name: "Inpainting (Background Estimation; Experimental, 432x240 only)",
            description: "Attempt to estimate the background behind the subject and fill the subject area with it",
            imagePath: '',
            parameterSchema: inpaintFormSchemaSubject,
            uiSchema: inpaintFormSchemaSubjectUI,
            defaultValues: {
                detectionParams: {
                    numPoses: 1,
                },
            }
        },
    },
    "background": {
        none: {
            name: "None",
            description: "Does not hide the background of the video",
            imagePath: '',
        },
        blur: {
            name: "Blur",
            description: "Gaussian Blurring",
            imagePath: '',
            parameterSchema: blurFormSchemaBG,
            defaultValues: {
                subjectDetection: "silhouette",
                detectionModel: "mediapipe",
                detectionParams: {
                    numPoses: 1,
                    confidence: 0.5
                },
                hidingParams: {
                    kernelSize: 23,
                }
            }
        },
        blackout: {
            name: "Blackout",
            description: "Hiding the subject with the selected color",
            imagePath: '',
            parameterSchema: blackoutFormSchemaBG,
            defaultValues: {
                subjectDetection: "silhouette",
                detectionModel: "mediapipe",
                detectionParams: {
                    numPoses: 1,
                    confidence: 0.5
                },
                hidingParams: {
                    color: 0,
                }
            }
        },
    }
}

export const voiceMaskingMethods: any = {
    preserve: {
        name: "Preserve",
        description: "Leave the video's audio unaltered",
        imagePath: '/images/voice_masking_strategy/preserve.svg',
        defaultValues: {}
    },
    remove: {
        name: "Remove",
        description: "Remove the video's audio entirely",
        imagePath: '/images/voice_masking_strategy/remove.svg',
        defaultValues: {}
    },
    switch: {
        name: "Switch",
        description: "Mask the original speaker by replacing their voice with the voice of another person",
        imagePath: '/images/voice_masking_strategy/switch.svg',
        parameterSchema: rvcSchema,
        defaultValues: {
            mode: 'manual',
            voice: "arianaGrande",
        }
    },
};
