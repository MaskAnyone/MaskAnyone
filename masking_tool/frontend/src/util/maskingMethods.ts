import { MaskingMethods } from "../state/types/RunParamRendering";
import { blackoutFormSchemaBG, blackoutFormSchemaSubject, blackoutFormSchemaSubjectUI, blurFormSchemaBG, blurFormSchemaSubject, blurFormSchemaSubjectUI, faceMeshFormSchema, skeletonFormSchema } from "./formSchemas";

export const maskingMethods: MaskingMethods = {
    face: {
        hidingMethods: {
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
        maskingMethods: {
            none: {
                name: "None",
                description: "Does not mask the subject in the video"
            },
            skeleton: {
                name: "Skeleton",
                description: "Displays a basic skeleton containing landmarks for eyes, nose and mouth in the video.",
                parameterSchema: skeletonFormSchema,
                defaultValues: {
                    maskingModel: "mediapipe",
                    numPoses: 1,
                    confidence: 0.5,
                    timeseries: false
                }
            },
            faceMesh: {
                name: "Detailed Face Mesh",
                description: "Displays a detailed facemesh containing 478 Landmarks",
                parameterSchema: faceMeshFormSchema,
                defaultValues: {
                    maskingModel: "mediapipe",
                    numPoses: 1,
                    confidence: 0.5,
                    timeseries: false
                }
            },
        },
    },
    body: {
        hidingMethods: {
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
        },
        maskingMethods: {
            none: {
                name: "None",
                description: "Does not mask the subject in the video"
            },
            skeleton: {
                name: "Skeleton",
                description: "Displays a skeleton containing landmarks for eyes, nose and mouth in the video.",
                parameterSchema: skeletonFormSchema,
                defaultValues: {
                    maskingModel: "mediapipe",
                    numPoses: 1,
                    confidence: 0.5,
                    timeseries: false
                }
            },
        },
    },
    "background": {
        hidingMethods: {
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
        },
    }
}
