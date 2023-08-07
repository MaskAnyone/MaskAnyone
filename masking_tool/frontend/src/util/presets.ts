import { Preset } from "../state/types/Run";
import { maskingMethods } from "./maskingMethods";

export const presetsDB: Preset[] = [
    {
        name: "Blur Face",
        detailText: "This preset will blur the face of detected persons in the video. Only the face will be blurred, the rest of the video will stay untouched.",
        runParams: {
            videoMasking: {
                hidingTarget: "face",
                hidingStrategyTarget: {
                    key: "blur",
                    params: maskingMethods["body"].hidingMethods!["blur"].defaultValues!
                },
                maskingStrategy: {
                    key: "none",
                    params: {}
                },
                hidingStrategyBG: {
                    key: "none",
                    params: {}
                }
            },
            threeDModelCreation: {
                skeleton: false,
                skeletonParams: {},
                blender: false,
                blenderParams: {},
                blendshapes: false,
                blendshapesParams: {}
            },
            voiceMasking: {}
        }
    },
    {
        name: "Mask Kinematics",
        runParams: {
            videoMasking: {
                hidingTarget: "body",
                hidingStrategyTarget: {
                    key: "blackout",
                    params: maskingMethods["body"].hidingMethods["blackout"].defaultValues!
                },
                maskingStrategy: {
                    key: "skeleton",
                    params: maskingMethods["body"].maskingMethods!["skeleton"].defaultValues!
                },
                hidingStrategyBG: {
                    key: "none",
                    params: {}
                }
            },
            threeDModelCreation: {
                skeleton: false,
                skeletonParams: {},
                blender: false,
                blenderParams: {},
                blendshapes: false,
                blendshapesParams: {}
            },
            voiceMasking: {}
        }
    },
    {
        name: "Video to 3D Character",
        runParams: {
            videoMasking: {
                hidingTarget: "none",
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
            threeDModelCreation: {
                skeleton: true,
                skeletonParams: {},
                blender: false,
                blenderParams: {},
                blendshapes: false,
                blendshapesParams: {}
            },
            voiceMasking: {}
        }
    },
    {
        name: "Replace Face (Coming Soon!)",
        runParams: {
            videoMasking: {
                hidingTarget: "none",
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
            threeDModelCreation: {
                skeleton: false,
                skeletonParams: {},
                blender: false,
                blenderParams: {},
                blendshapes: false,
                blendshapesParams: {}
            },
            voiceMasking: {}
        }
    },
    {
        name: "Blur Background",
        runParams: {
            videoMasking: {
                hidingTarget: "none",
                hidingStrategyTarget: {
                    key: "none",
                    params: {}
                },
                hidingStrategyBG: {
                    key: "blur",
                    params: maskingMethods["background"].hidingMethods!["blur"].defaultValues!
                },
                maskingStrategy: {
                    key: "none",
                    params: {}
                }
            },
            threeDModelCreation: {
                skeleton: false,
                skeletonParams: {},
                blender: false,
                blenderParams: {},
                blendshapes: false,
                blendshapesParams: {}
            },
            voiceMasking: {}
        }
    },
]