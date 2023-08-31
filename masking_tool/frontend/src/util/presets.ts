import { Preset } from "../state/types/Run";
import { hidingMethods, maskingMethods } from "./maskingMethods";

export const presetsDB: Preset[] = [
    {
        name: "Blur Face",
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
