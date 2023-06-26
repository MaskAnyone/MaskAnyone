import { MaskingMethods } from "../state/types/RunParamRendering";
import { blackoutFormSchemaBG, blackoutFormSchemaSubject, blurFormSchemaBG, blurFormSchemaSubject, faceMeshFormSchema, skeletonFormSchema } from "./formSchemas";

export const maskingMethods: MaskingMethods = {
    head : {
        hidingMethods: {
            blur: {
                name: "Blur",
                description: "Gaussian Blurring",
                parameterSchema: blurFormSchemaSubject
            },
            blackout: {
                name: "Blackout",
                description: "Hiding the subject with the selected color",
                parameterSchema: blackoutFormSchemaSubject
            },
        },
        maskingMethods: {
            skeleton: {
                name: "Skeleton",
                description: "Displays a basic skeleton containing landmarks for eyes, nose and mouth in the video.",
                parameterSchema: skeletonFormSchema
            },
            faceMesh: {
                name: "Detailed Face Mesh",
                description: "Displays a detailed facemesh containing 478 Landmarks",
                parameterSchema: faceMeshFormSchema
            },
        },
    },
    body: {
        hidingMethods: {
            blur: {
                name: "Blur",
                description: "Gaussian Blurring",
                parameterSchema: blurFormSchemaSubject
            },
            blackout: {
                name: "Blackout",
                description: "Hiding the subject with the selected color",
                parameterSchema: blackoutFormSchemaSubject
            },
        },
        maskingMethods: {
            skeleton: {
                name: "Skeleton",
                description: "Displays a skeleton containing landmarks for eyes, nose and mouth in the video.",
                parameterSchema: skeletonFormSchema
            },
        },
    },
    "background": {
        hidingMethods: {
            blur: {
                name: "Blur",
                description: "Gaussian Blurring",
                parameterSchema: blurFormSchemaBG
            },
            blackout: {
                name: "Blackout",
                description: "Hiding the subject with the selected color",
                parameterSchema: blackoutFormSchemaBG
            },
        },
    }
}
