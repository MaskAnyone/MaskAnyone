import { Box, Button, Typography } from "@mui/material";
import SelectableCard from "../../../../common/SelectableCard";
import { StepProps } from "./HidingStep";
import { maskingMethods } from "../../../../../util/maskingMethods";
import MethodSettings from "../../MethodSettings";

const VideoMaskingStep = (props: StepProps) => {
    const maskingStrategy = props.runParams.videoMasking.maskingStrategy

    const setMaskingStrategy = (newMaskingStrategy: string) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                maskingStrategy: {
                    key: newMaskingStrategy,
                    params: maskingMethods[newMaskingStrategy].defaultValues!
                }
            }
        })
    }

    const setMaskingStrategyParams = (newParams: object) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                maskingStrategy: {
                    ...props.runParams.videoMasking.maskingStrategy,
                    params: newParams
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
                        formSchema={maskingMethods[maskingStrategy.key].parameterSchema}
                        uiSchema={maskingMethods[maskingStrategy.key].uiSchema}
                        values={maskingStrategy.params}
                        onSet={setMaskingStrategyParams}
                    />
                </Button>
            </Typography >

        </Box>
    )
}

export default VideoMaskingStep