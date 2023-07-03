import { Button, Grid, Paper, Typography } from "@mui/material";
import { Box } from "@mui/system";
import PresetItem from "./PresetItem";
import TuneIcon from '@mui/icons-material/Tune';
import { useState } from "react";
import { Preset, RunParams } from "../../state/types/Run";
import { maskingMethods } from "../../util/maskingMethods";

interface PresetSelectionProps {
    onPresetSelect: (runParams: RunParams) => void
    onCustomModeRequested: () => void
}

 const mockPresets: Preset[] = [
    {
        name: "Blur Face",
        detailText: "This preset will blur the face of detected persons in the video. Only the face will be blurred, the rest of the video will stay untouched.",
        runParams: {
            videoMasking: {
                "body": {
                    hidingStrategy: {
                        key: "none",
                        params: {}
                    }, maskingStrategy: {
                        key: "none",
                        params: {}
                    }
                },
                "head": {
                    hidingStrategy: {
                        key: "blur",
                        params: maskingMethods["body"].hidingMethods!["blur"].defaultValues!
                    }, maskingStrategy: {
                        key: "none",
                        params: {}
                    }
                },
                "background": {
                    hidingStrategy: {
                        key: "none",
                        params: {}
                    }, maskingStrategy: {
                        key: "none",
                        params: {}
                    }
                }
            },
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
    {
        name: "Mask Kinematics",
        runParams: {
            videoMasking: {
                "body": {
                    hidingStrategy: {
                        key: "blackout",
                        params: maskingMethods["body"].hidingMethods["blackout"].defaultValues!
                    }, maskingStrategy: {
                        key: "skeleton",
                        params: maskingMethods["body"].maskingMethods!["skeleton"].defaultValues!
                    }
                },
                "head": {
                    hidingStrategy: {
                        key: "blackout",
                        params: maskingMethods["head"].hidingMethods["blackout"].defaultValues!
                    }, maskingStrategy: {
                        key: "skeleton",
                        params: maskingMethods["head"].maskingMethods!["skeleton"].defaultValues!
                    }
                },
                "background": {
                    hidingStrategy: {
                        key: "none",
                        params: {}
                    }, maskingStrategy: {
                        key: "none",
                        params: maskingMethods["background"].hidingMethods!["blur"].defaultValues!
                    }
                }
            },
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
    {
        name: "Video to 3D Character",
        runParams: {
            videoMasking: {},
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
    {
        name: "Replace Face (Coming Soon!)",
        runParams: {
            videoMasking: {},
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
    {
        name: "Blur Background",
        runParams: {
            videoMasking: {
                "body": {
                    hidingStrategy: {
                        key: "none",
                        params: {}
                    }, maskingStrategy: {
                        key: "none",
                        params: {}
                    }
                },
                "head": {
                    hidingStrategy: {
                        key: "none",
                        params: {}
                    }, maskingStrategy: {
                        key: "none",
                        params: {}
                    }
                },
                "background": {
                    hidingStrategy: {
                        key: "blur",
                        params: {}
                    }, maskingStrategy: {
                        key: "none",
                        params: {}
                    }
                }
            },
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
]

const PresetSelection = (props: PresetSelectionProps) => {
    const [presets, setPresets] = useState(mockPresets)
    const [selected, setSelected] = useState<string | undefined>()

    const onPresetClicked = (preset: Preset) => {
        setSelected(preset.name)
        props.onPresetSelect(preset.runParams)
    }

    return(
                <Grid container rowSpacing={2} columnSpacing={{ xs: 1, sm: 2, md: 3 }} xs={12} marginTop={"10px"}>
                    {presets.map((preset, index) => {
                        return(
                            <Grid item xs={4}>
                                <PresetItem
                                    name={preset.name}
                                    selected={selected==preset.name}
                                    previewImagePath={preset.previewImagePath}
                                    description={preset.detailText}
                                    onClick={() => onPresetClicked(preset)}
                                />
                            </Grid>
                        )
                    })}
                    <Grid item xs={4}>
                        <PresetItem
                            name="Custom Run"
                            icon={<TuneIcon/>}
                            selected={false}
                            onClick={() => props.onCustomModeRequested()}
                        />
                    </Grid>
                </Grid>
    )
}

export default PresetSelection