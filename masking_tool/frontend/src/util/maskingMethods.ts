import { HidingMethods, MaskingMethods } from "../state/types/RunParamRendering";
import { faceswapFormSchema, blackoutFormSchemaBG, blackoutFormSchemaSubject, blackoutFormSchemaSubjectUI, blurFormSchemaBG, blurFormSchemaSubject, blurFormSchemaSubjectUI, bodyMeshFormSchema, faceMeshFormSchema, inpaintFormSchemaSubject, inpaintFormSchemaSubjectUI, rvcSchema, skeletonFormSchema } from "./formSchemas";

export const maskingMethods: MaskingMethods = {
    none: {
        name: "None",
        description: "Does not mask the subject in the video"
    },
    skeleton: {
        name: "Skeleton",
        description: "Displays a basic skeleton containing landmarks for the head, torso, arms and legs",
        parameterSchema: skeletonFormSchema,
        defaultValues: {
            maskingModel: "mediapipe",
            numPoses: 1,
            confidence: 0.5,
            timeseries: false
        },
        backendFormat: {
            "body": "skeleton"
        }
    },
    faceSwap: {
        name: "Face Swap",
        description: "Swaps the face of the subject with the face of another person",
        parameterSchema: faceswapFormSchema,
        defaultValues: {
            sourceImage: "neutral",
            maskingModel: "roop"
        },
        backendFormat: {
            "face": "swap"
        }
    },
    faceMesh: {
        name: "Face Mesh",
        description: "Displays a detailed facemesh containing 478 Landmarks",
        parameterSchema: faceMeshFormSchema,
        defaultValues: {
            maskingModel: "mediapipe",
            numPoses: 1,
            confidence: 0.5,
            timeseries: false
        },
        backendFormat: {
            "face": "faceMesh"
        }
    },
    faceMeshSkeleton: {
        name: "Skeleton & Face Mesh",
        description: "Displays a skeleton with a detailed facemesh containing 478 Landmarks",
        parameterSchema: faceMeshFormSchema,
        defaultValues: {
            maskingModel: "mediapipe",
            numPoses: 1,
            confidence: 0.5,
            timeseries: false
        },
        backendFormat: {
            "body": "skeleton",
            "face": "faceMesh"
        }
    }
}

export const hidingMethods: HidingMethods = {
    face: {
        none: {
            name: "None",
            description: "Does not hide the subject in the video"
        },
        blur: {
            name: "Blur",
            description: "Gaussian Blurring",
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
            description: "Does not hide the subject in the video"
        },
        blur: {
            name: "Blur",
            description: "Gaussian Blurring",
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
        inpaint: {
            name : "Inpainting (Background Estimation; Experimental, 432x240 only)",
            description: "Attempt to estimate the background behind the subject and fill the subject area with it",
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
            description: "Does not hide the background of the video"
        },
        blur: {
            name: "Blur",
            description: "Gaussian Blurring",
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
        defaultValues: {}
    },
    remove: {
        name: "Remove",
        description: "Remove the video's audio entirely",
        defaultValues: {}
    },
    switch: {
        name: "Switch",
        description: "Mask the original speaker by replacing their voice with the voice of another person",
        parameterSchema: rvcSchema,
        defaultValues: {
            mode: 'manual',
            voice: "arianaGrande",
        }
    },
};
