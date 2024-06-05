import { Box, Typography } from "@mui/material";
import SelectableCard from "../../../../common/SelectableCard";
import {StepProps} from "./StepProps";

const VideoMaskingStep = (props: StepProps) => {
    const maskingStrategy = props.runParams.videoMasking.strategy;

    const setMaskingStrategy = (newMaskingStrategy: string) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                strategy: newMaskingStrategy,
            }
        })
    }

    return (
        <Box component="div">
            <Box component={'div'} sx={{ marginBottom: 3.5 }}>
                <Typography variant="h6">
                    What masking strategy do you want to apply?
                </Typography >
                <Typography variant={'body2'}>
                    Please select the masking strategy you would like to apply. The different masking strategies offer various ways trade-offs between privacy and utility.
                </Typography>
            </Box>
            <Box component="div" sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '24px' }} mt={1}>
                <SelectableCard
                    title={'Blurring'}
                    description={'Displays a basic skeleton containing landmarks for the head, torso, arms and legs'}
                    imagePath={'/images/masking_strategy/skeleton.jpg'}
                    onSelect={() => setMaskingStrategy('blurring')}
                    selected={maskingStrategy === 'blurring'}
                />
                <SelectableCard
                    title={'Blackout'}
                    description={'Displays a basic skeleton containing landmarks for the head, torso, arms and legs'}
                    imagePath={'/images/masking_strategy/skeleton.jpg'}
                    onSelect={() => setMaskingStrategy('blackout')}
                    selected={maskingStrategy === 'blackout'}
                />
            </Box>

        </Box>
    )
}

export default VideoMaskingStep
