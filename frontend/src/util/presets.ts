import { Preset } from "../state/types/Run";
import { hidingMethods, maskingMethods } from "./maskingMethods";

export const presetsDB: Preset[] = [
    {
        id: '5423ea71-8a7c-4cad-99da-0147c34afc43',
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
        id: '90d8641c-f7bb-46b4-b6ec-3b6c29dd6c9c',
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
        id: 'c1dfe09d-eeb9-43ed-af82-a66ea033df48',
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
        id: 'fe5572a4-a8c9-4524-81bd-b3d151322c6f',
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
        id: '0b45e5af-5c32-45fe-b618-51b0a065448c',
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
        id: '75fe7061-cb08-4619-9532-5cfd770bdc75',
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
        id: 'c65fbcad-c959-4fa5-a1e9-62c3a5900884',
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
        id: '12ba1f6f-c4dd-4eda-aefd-a89d30a965e3',
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
        id: 'b87a182e-b149-4d2f-a4d4-f7aef0243bea',
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
