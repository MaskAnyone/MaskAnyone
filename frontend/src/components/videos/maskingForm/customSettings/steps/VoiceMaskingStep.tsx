import { Box, Typography } from "@mui/material";
import { voiceMaskingMethods } from "../../../../../util/maskingMethods";
import SelectableCard from "../../../../common/SelectableCard";
import {StepProps} from "./StepProps";

const VoiceMaskingStep = (props: StepProps) => {
    const maskingStrategy = props.runParams.voiceMasking.strategy;

    const setMaskingStrategy = (newMaskingStrategy: string) => {
        props.onParamsChange({
            ...props.runParams,
            voiceMasking: {
                ...props.runParams.voiceMasking,
                strategy: newMaskingStrategy,
            }
        });
    };

    return (
        <>
            <Box component={'div'} sx={{ marginBottom: 3.5 }}>
                <Typography variant="h6">
                    Do you want to mask the voice too?
                </Typography >
                <Typography variant={'body2'}>
                    Please choose how you want to mask the video's audio content.
                </Typography>
            </Box>
            <Box component="div" sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '24px' }} mt={1}>
                {
                    Object.keys(voiceMaskingMethods).map((methodName) => {
                        const voiceMaskingMethod = voiceMaskingMethods[methodName];

                        return (
                            <SelectableCard
                                title={voiceMaskingMethod.name}
                                description={voiceMaskingMethod.description}
                                imagePath={voiceMaskingMethod.imagePath}
                                onSelect={() => setMaskingStrategy(methodName)}
                                selected={maskingStrategy === methodName}
                            />
                        )
                    })
                }
            </Box>
        </>
    )
}

export default VoiceMaskingStep
