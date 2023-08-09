import { Box, Typography } from "@mui/material";
import SelectableCard from "../../../../common/SelectableCard";
import { StepProps } from "./HidingStep";
import { maskingMethods } from "../../../../../util/maskingMethods";

const VideoMaskingStep = (props: StepProps) => {
    const maskingMethod = props.runParams.videoMasking.maskingStrategy.key

    const setMaskingStrategy = (maskingStrategy: string) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                maskingStrategy: {
                    key: maskingStrategy,
                    params: {}
                }
            }
        })
    }

    return (
        <Box component="div" mt={3}>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
                Select a masking strategy
            </Typography >
            <Box component="div" sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '15px' }} mt={1}>
                {
                    Object.keys(maskingMethods).map((methodName) => {
                        return (
                            <SelectableCard
                                title={maskingMethods[methodName].name}
                                description={maskingMethods[methodName].description}
                                imagePath={""}
                                onSelect={() => setMaskingStrategy(maskingMethods[methodName].name)}
                                selected={maskingMethod == maskingMethods[methodName].name}
                            />
                        )
                    })
                }
            </Box>
        </Box>
    )
}

export default VideoMaskingStep