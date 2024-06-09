import {Box, Checkbox, Slider, Switch, Typography} from "@mui/material";
import SelectableCard from "../../../../common/SelectableCard";
import {StepProps} from "./StepProps";

const VideoMaskingStep = (props: StepProps) => {
    const maskingStrategy = props.runParams.videoMasking;

    const setMaskingStrategy = (newMaskingStrategy: string) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                strategy: newMaskingStrategy,
            }
        })
    };

    const setMaskingStrategyLevel = (level: number) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                options: {
                    ...props.runParams.videoMasking.options,
                    level: level,
                }
            }
        });
    };

    const setMaskingStrategySkeleton = (skeleton: boolean) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                options: {
                    ...props.runParams.videoMasking.options,
                    skeleton,
                }
            }
        });
    };

    const setMaskingStrategyAverageColor = (averageColor: boolean) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                options: {
                    ...props.runParams.videoMasking.options,
                    averageColor,
                }
            }
        });
    };

    const setMaskingStrategyColor = (hexColor: string) => {
        props.onParamsChange({
            ...props.runParams,
            videoMasking: {
                ...props.runParams.videoMasking,
                options: {
                    ...props.runParams.videoMasking.options,
                    color: hexColor,
                }
            }
        });
    };

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
                    selected={maskingStrategy.strategy === 'blurring'}
                />
                <SelectableCard
                    title={'Pixelation'}
                    description={'Displays a basic skeleton containing landmarks for the head, torso, arms and legs'}
                    imagePath={'/images/masking_strategy/skeleton.jpg'}
                    onSelect={() => setMaskingStrategy('pixelation')}
                    selected={maskingStrategy.strategy === 'pixelation'}
                />
                <SelectableCard
                    title={'Contours'}
                    description={'Displays a basic skeleton containing landmarks for the head, torso, arms and legs'}
                    imagePath={'/images/masking_strategy/skeleton.jpg'}
                    onSelect={() => setMaskingStrategy('contours')}
                    selected={maskingStrategy.strategy === 'contours'}
                />
                <SelectableCard
                    title={'Solid Fill'}
                    description={'Displays a basic skeleton containing landmarks for the head, torso, arms and legs'}
                    imagePath={'/images/masking_strategy/skeleton.jpg'}
                    onSelect={() => setMaskingStrategy('solid_fill')}
                    selected={maskingStrategy.strategy === 'solid_fill'}
                />
            </Box>
            <Box component={'div'} sx={{ marginTop: 2 }}>
                <Typography variant="h6">
                    Options for {maskingStrategy.strategy}
                </Typography>
                <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
                    <Typography variant={'body2'}>
                        Include skeleton overlay:
                    </Typography>
                    <Checkbox
                        checked={maskingStrategy.options.skeleton}
                        onChange={(event, newValue) => setMaskingStrategySkeleton(newValue)}
                    />
                </Box>
                {maskingStrategy.strategy !== 'solid_fill' && (
                    <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
                        <Typography variant={'body2'}>
                            Masking level (1 = weak to 5 = strong):
                        </Typography>
                        <Slider
                            min={1}
                            max={5}
                            step={1}
                            sx={{ maxWidth: 200, marginLeft: 2 }}
                            value={maskingStrategy.options.level}
                            onChange={(event, newValue) => setMaskingStrategyLevel(newValue as number)}
                        />
                    </Box>
                )}
                {maskingStrategy.strategy === 'solid_fill' && (
                    <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
                        <Typography variant={'body2'}>
                            Fill color (average or explicit):
                        </Typography>
                        <Switch
                            checked={maskingStrategy.options.averageColor}
                            onChange={(event, newValue) => setMaskingStrategyAverageColor(newValue)}
                        />
                        {!maskingStrategy.options.averageColor && (
                            <input
                                type={'color'}
                                value={maskingStrategy.options.color}
                                onChange={e => setMaskingStrategyColor(e.target.value)}
                                style={{ marginLeft: 12 }}
                            />
                        )}
                    </Box>
                )}
            </Box>
        </Box>
    )
}

export default VideoMaskingStep
