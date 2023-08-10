import { RJSFSchema, UiSchema } from "@rjsf/utils"

export type Method = {
    name: string,
    description: string,
    parameterSchema?: RJSFSchema
    uiSchema?: UiSchema
    defaultValues?: { [paramterName: string]: any }
    backendFormat?: {
        [target: string]: string
    }
}

export type HidingMethods = {
    [videoPart: string]: {
        [methodName: string]: Method
    }
}

export type MaskingMethods = {
    [maskingMethod: string]: Method
}