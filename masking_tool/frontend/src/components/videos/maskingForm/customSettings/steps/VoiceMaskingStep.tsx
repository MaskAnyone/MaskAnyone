import {Box, Typography} from "@mui/material";
import { StepProps } from "./HidingStep";
import {voiceMaskingMethods} from "../../../../../util/maskingMethods";
import SelectableCard from "../../../../common/SelectableCard";

const VoiceMaskingStep = (props: StepProps) => {
    const hidingStrategy = props.runParams.voiceMasking.hidingStrategy;

    const setHidingStrategy = (newHidingStrategy: string) => {
        props.onParamsChange({
            ...props.runParams,
            voiceMasking: {
                ...props.runParams.voiceMasking,
                hidingStrategy: {
                    key: newHidingStrategy,
                    params: voiceMaskingMethods[newHidingStrategy].defaultValues!
                }
            }
        })
    }

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
                        return (
                            <SelectableCard
                                title={voiceMaskingMethods[methodName].name}
                                description={voiceMaskingMethods[methodName].description}
                                imagePath={""}
                                onSelect={() => setHidingStrategy(methodName)}
                                selected={hidingStrategy.key == methodName}
                            />
                        )
                    })
                }
            </Box>
        </>
    )
}

export default VoiceMaskingStep
