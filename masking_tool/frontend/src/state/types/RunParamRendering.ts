import { RJSFSchema, UiSchema } from "@rjsf/utils"

export type Method = {
    name: string,
    description: string, 
    parameterSchema: RJSFSchema
    uiSchema?: UiSchema
}

export type MaskingMethods = {
    [videoPart: string]: {
        hidingMethods: {
            [methodName: string]: Method
        }
        maskingMethods?: {
            [methodName: string]: Method
        }
    }
}