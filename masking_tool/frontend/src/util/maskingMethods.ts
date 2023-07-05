import { MaskingMethods } from "../state/types/RunParamRendering";
import { blackoutFormSchemaBG, blackoutFormSchemaSubject, blackoutFormSchemaSubjectUI, blurFormSchemaBG, blurFormSchemaSubject, blurFormSchemaSubjectUI, faceMeshFormSchema, skeletonFormSchema } from "./formSchemas";

export const maskingMethods: MaskingMethods = {
    head : {
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
                    kernelSize: 23,
                    extraPixels: 0
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
                    color: "#000",
                    extraPixels: 0

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
                    num_poses: 1,
                    confidence: 1
                }
            },
            faceMesh: {
                name: "Detailed Face Mesh",
                description: "Displays a detailed facemesh containing 478 Landmarks",
                parameterSchema: faceMeshFormSchema,
                defaultValues: {
                    num_faces: 1,
                    confidence: 1
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
                    kernelSize: 23,
                    extraPixels: 0
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
                    color: "#000",
                    extraPixels: 0

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
                    num_poses: 1,
                    confidence: 1
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
                    kernelSize: 23,
                }
            },
            blackout: {
                name: "Blackout",
                description: "Hiding the subject with the selected color",
                parameterSchema: blackoutFormSchemaBG,
                defaultValues: {
                    color: "#000",
                }
            },
        },
    }
}
