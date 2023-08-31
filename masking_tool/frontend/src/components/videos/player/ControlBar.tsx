import {Box, IconButton, Slider, Typography} from "@mui/material";
import FastRewindIcon from '@mui/icons-material/FastRewind';
import FastForwardIcon from '@mui/icons-material/FastForward';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';
import PauseIcon from '@mui/icons-material/Pause';
import SpeedIcon from '@mui/icons-material/Speed';
import VolumeUpIcon from '@mui/icons-material/VolumeUp';
import TimerDisplay from "../../common/TimerDisplay";

interface ControlBarProps {
    playing: boolean;
    onTogglePlaying: (playing: boolean) => void;
    seeking: boolean;
    onToggleSeeking: (seeking: boolean) => void;
    position: number;
    onPositionChange: (newPosition: number) => void;
    playedSeconds: number;
    duration: number;
}

const ControlBar = (props: ControlBarProps) => {
    return (
        <Box component={'div'} sx={{ display: 'flex', flexDirection: 'column', width: '100%', paddingLeft: '24px' }}>
            <Box component={'div'}>
                <Slider
                    min={0}
                    max={0.99999999}
                    step={0.00000001}
                    value={props.position}
                    onMouseDown={() => props.onToggleSeeking(true)}
                    onChange={(_e, newValue) => props.onPositionChange(newValue as number)}
                    onMouseUp={() => props.onToggleSeeking(false)}
                />
            </Box>
            <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', width: '100%' }}>
                <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', alignItems: 'center'}}>
                    <TimerDisplay timeInSeconds={props.playedSeconds} />
                    <Typography variant={'body1'} sx={{ fontSize: '1.2rem', paddingLeft: 1, paddingRight: 1 }}>/</Typography>
                    <TimerDisplay timeInSeconds={props.duration} />
                </Box>
                <Box component={'div'}>
                    <IconButton><FastRewindIcon /></IconButton>

                    {props.playing ? (
                        <IconButton onClick={() => props.onTogglePlaying(false)}><PauseIcon /></IconButton>
                    ): (
                        <IconButton onClick={() => props.onTogglePlaying(true)}><PlayArrowIcon /></IconButton>
                    )}

                    <IconButton><FastForwardIcon /></IconButton>
                </Box>
                <Box component={'div'}>
                    <IconButton><SpeedIcon /></IconButton>
                    <IconButton><VolumeUpIcon /></IconButton>
                </Box>
            </Box>
        </Box>
    );
};

export default ControlBar;
