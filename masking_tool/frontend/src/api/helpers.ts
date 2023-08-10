import { RunParams } from "../state/types/Run";
import { maskingMethods } from "../util/maskingMethods";

export function asBackendRunData(runData: RunParams) {
    const videoMaskingParams: any = {}
    const hidingTarget = runData.videoMasking.hidingTarget
    if (hidingTarget !== "none") {
        videoMaskingParams[hidingTarget] = {
            hidingStrategy: {
                key: runData.videoMasking.hidingStrategyTarget.key,
                params: runData.videoMasking.hidingStrategyTarget.params
            },
            maskingStrategy: {
                key: "none",
                params: {}
            }
        }
    }
    if (runData.videoMasking.hidingStrategyBG.key != "none") {
        videoMaskingParams["background"] = {
            hidingStrategy: {
                key: runData.videoMasking.hidingStrategyBG.key,
                params: runData.videoMasking.hidingStrategyBG.params
            },
            maskingStrategy: {
                key: "none",
                params: {}
            }
        }
    }
    if (runData.videoMasking.maskingStrategy.key != "none") {
        const maskingStrategyBackendFormat = maskingMethods[runData.videoMasking.maskingStrategy.key].backendFormat!
        console.log(maskingStrategyBackendFormat)
        for (const target of Object.keys(maskingStrategyBackendFormat)) {
            if (target in videoMaskingParams) {
                videoMaskingParams[target]["maskingStrategy"] = {
                    key: maskingStrategyBackendFormat[target],
                    params: runData.videoMasking.maskingStrategy.params
                }
            } else {
                videoMaskingParams[target] = {
                    hidingStrategy: {
                        key: "none",
                        params: {}
                    },
                    maskingStrategy: {
                        key: maskingStrategyBackendFormat[target],
                        params: runData.videoMasking.maskingStrategy.params
                    }
                }
            }
        }
    }
    return {
        videoMasking: videoMaskingParams,
        threeDModelCreation: runData.threeDModelCreation,
        voiceMasking: runData.voiceMasking,
    }
}