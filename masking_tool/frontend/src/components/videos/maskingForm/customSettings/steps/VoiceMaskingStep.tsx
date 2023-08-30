import { Box, Button, Typography } from "@mui/material";
import { StepProps } from "./HidingStep";
import { voiceMaskingMethods } from "../../../../../util/maskingMethods";
import SelectableCard from "../../../../common/SelectableCard";
import MethodSettings from "../../MethodSettings";

const VoiceMaskingStep = (props: StepProps) => {
    const maskingStrategy = props.runParams.voiceMasking.maskingStrategy;

    const setMaskingStrategy = (newMaskingStrategy: string) => {
        props.onParamsChange({
            ...props.runParams,
            voiceMasking: {
                ...props.runParams.voiceMasking,
                maskingStrategy: {
                    key: newMaskingStrategy,
                    params: voiceMaskingMethods[newMaskingStrategy].defaultValues!
                }
            }
        })
    }

    const setVoiceMaskingStrategyParams = (newParams: object) => {
        props.onParamsChange({
            ...props.runParams,
            voiceMasking: {
                ...props.runParams.voiceMasking,
                maskingStrategy: {
                    ...props.runParams.voiceMasking.maskingStrategy,
                    params: newParams
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
                        const voiceMaskingMethod = voiceMaskingMethods[methodName];

                        return (
                            <SelectableCard
                                title={voiceMaskingMethod.name}
                                description={voiceMaskingMethod.description}
                                imagePath={voiceMaskingMethod.imagePath}
                                onSelect={() => setMaskingStrategy(methodName)}
                                selected={maskingStrategy.key == methodName}
                            />
                        )
                    })
                }
            </Box>
            <Typography variant="body1" sx={{ fontWeight: 500 }} mt={3}>
                Edit fine-grained settings of selected masking method:
                <Button>
                    <MethodSettings
                        methodName={maskingStrategy.key}
                        formSchema={voiceMaskingMethods[maskingStrategy.key].parameterSchema}
                        uiSchema={voiceMaskingMethods[maskingStrategy.key].uiSchema}
                        values={maskingStrategy.params}
                        onSet={setVoiceMaskingStrategyParams}
                    />
                </Button>
            </Typography >
        </>
    )
}

export default VoiceMaskingStep
