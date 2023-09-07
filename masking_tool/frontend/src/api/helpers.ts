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

export function asFrontendRunParams(backendRunData: any): RunParams {
    const videoMaskingParams = backendRunData.videoMasking;
    const hidingTargets = Object.keys(videoMaskingParams);

    const runData: RunParams = {
        videoMasking: {
            hidingTarget: hidingTargets.length > 0 ? hidingTargets[0] as any : "none",
            hidingStrategyTarget: {
                key: "none",
                params: {}
            },
            hidingStrategyBG: {
                key: "none",
                params: {}
            },
            maskingStrategy: {
                key: "none",
                params: {}
            }
        },
        threeDModelCreation: backendRunData.threeDModelCreation,
        voiceMasking: backendRunData.voiceMasking
    };

    for (const hidingTarget of hidingTargets) {
        const hidingStrategy = videoMaskingParams[hidingTarget].hidingStrategy;
        const maskingStrategy = videoMaskingParams[hidingTarget].maskingStrategy;

        if (hidingTarget === "background") {
            runData.videoMasking.hidingStrategyBG.key = hidingStrategy.key;
            runData.videoMasking.hidingStrategyBG.params = hidingStrategy.params;
        } else if(hidingStrategy.key !== "none") {
            runData.videoMasking.hidingTarget = hidingTarget as any;
            runData.videoMasking.hidingStrategyTarget.key = hidingStrategy.key;
            runData.videoMasking.hidingStrategyTarget.params = hidingStrategy.params;
        }

        if (maskingStrategy.key !== "none") {
            runData.videoMasking.maskingStrategy.key = maskingStrategy.key;
            runData.videoMasking.maskingStrategy.params = maskingStrategy.params;
        }
    }

    return runData;
}
