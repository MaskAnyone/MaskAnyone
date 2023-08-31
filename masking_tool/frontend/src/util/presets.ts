import { Preset } from "../state/types/Run";
import { hidingMethods, maskingMethods } from "./maskingMethods";

export const presetsDB: Preset[] = [
    {
        name: "Blur Face",
        previewImagePath: "/images/presets/blurFace.png",
        detailText: "This preset will blur the face of detected persons in the video. Only the face will be blurred, the rest of the video will stay untouched.",
        runParams: {
            videoMasking: {
                hidingTarget: "face",
                hidingStrategyTarget: {
                    key: "blur",
                    params: hidingMethods["face"]["blur"].defaultValues!
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
            voiceMasking: {
                maskingStrategy: {
                    key: 'preserve',
                    params: {},
                }
            }
        }
    },
    {
        name: "Mask Kinematics (Medium Privacy)",
        previewImagePath: "/images/presets/kinematicsMedium.png",
        runParams: {
            videoMasking: {
                hidingTarget: "body",
                hidingStrategyTarget: {
                    key: "blur",
                    params: hidingMethods["body"]["blur"].defaultValues!
                },
                maskingStrategy: {
                    key: "faceMeshSkeleton",
                    params: maskingMethods!["faceMeshSkeleton"].defaultValues!
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
            voiceMasking: {
                maskingStrategy: {
                    key: 'preserve',
                    params: {},
                }
            }
        }
    },
    {
        name: "Mask Kinematics (High Privacy)",
        previewImagePath: "/images/presets/kinematicsMax.png",
        runParams: {
            videoMasking: {
                hidingTarget: "body",
                hidingStrategyTarget: {
                    key: "blackout",
                    params: hidingMethods["body"]["blackout"].defaultValues!
                },
                maskingStrategy: {
                    key: "faceMeshSkeleton",
                    params: maskingMethods!["faceMeshSkeleton"].defaultValues!
                },
                hidingStrategyBG: {
                    key: "blur",
                    params: hidingMethods["background"]!["blur"].defaultValues!
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
            voiceMasking: {
                maskingStrategy: {
                    key: 'remove',
                    params: {},
                }
            }
        }
    },
    {
        name: "Extract Blender Character",
        previewImagePath: "/images/presets/blender_3d_character.jpg",
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
                blender: true,
                blenderParams: {
                    maskingModel: "blender",
                    character: "rigged_char",
                    render: 0,
                    export: 1,
                    smoothing: 0
                },
                blendshapes: false,
                blendshapesParams: {}
            },
            voiceMasking: {
                maskingStrategy: {
                    key: 'preserve',
                    params: {},
                }
            }
        }
    },
    {
        name: "Extract 3D Skeleton",
        previewImagePath: "/images/presets/skeleton.png",
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
            voiceMasking: {
                maskingStrategy: {
                    key: 'preserve',
                    params: {},
                }
            }
        }
    },
    {
        name: "Replace Face",
        previewImagePath: "/images/presets/face_swap.jpg",
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
                    key: "faceSwap",
                    params: maskingMethods!["faceSwap"].defaultValues!
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
            voiceMasking: {
                maskingStrategy: {
                    key: 'preserve',
                    params: {},
                }
            }
        }
    },
    {
        name: "Contours Masking",
        previewImagePath: "/images/presets/contours.png",
        runParams: {
            videoMasking: {
                hidingTarget: "body",
                hidingStrategyTarget: {
                    key: "contour",
                    params: hidingMethods["body"]["contour"].defaultValues!
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
            voiceMasking: {
                maskingStrategy: {
                    key: 'preserve',
                    params: {},
                }
            }
        }
    },
    {
        name: "Blur Background",
        previewImagePath: "/images/presets/blurBG.png",
        runParams: {
            videoMasking: {
                hidingTarget: "none",
                hidingStrategyTarget: {
                    key: "none",
                    params: {}
                },
                hidingStrategyBG: {
                    key: "blur",
                    params: hidingMethods["background"]!["blur"].defaultValues!
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
            voiceMasking: {
                maskingStrategy: {
                    key: 'preserve',
                    params: {},
                }
            }
        }
    },
    {
        name: "Switch Voice",
        previewImagePath: "/images/presets/none.jpg",
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
            voiceMasking: {
                maskingStrategy: {
                    key: 'switch',
                    params: {
                        'mode': 'manual',
                        'voice': 'arianaGrande'
                    },
                }
            }
        }
    },
]
