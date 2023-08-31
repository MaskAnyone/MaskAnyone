import {Box, IconButton, Menu, MenuItem, Slider, Typography} from "@mui/material";
import FastRewindIcon from '@mui/icons-material/FastRewind';
import FastForwardIcon from '@mui/icons-material/FastForward';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';
import PauseIcon from '@mui/icons-material/Pause';
import SpeedIcon from '@mui/icons-material/Speed';
import VolumeUpIcon from '@mui/icons-material/VolumeUp';
import TimerDisplay from "../../common/TimerDisplay";
import React, {useState} from "react";

interface ControlBarProps {
    playing: boolean;
    onTogglePlaying: (playing: boolean) => void;
    seeking: boolean;
    onToggleSeeking: (seeking: boolean) => void;
    position: number;
    onPositionChange: (newPosition: number) => void;
    playedSeconds: number;
    duration: number;
    video2Available: boolean;
    volume1: number;
    volume2: number;
    onVolume1Change: (volume1: number) => void;
    onVolume2Change: (volume1: number) => void;
}

const ControlBar = (props: ControlBarProps) => {
    const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
    const open = Boolean(anchorEl);
    const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
        setAnchorEl(event.currentTarget);
    };
    const handleClose = () => {
        setAnchorEl(null);
    };

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
                    <IconButton onClick={handleClick}><VolumeUpIcon /></IconButton>
                </Box>

                <Menu anchorEl={anchorEl} open={open} onClose={handleClose}>
                    <Box component={'div'} sx={{ padding: '8px 24px' }}>
                        <Box component={'div'} sx={{ width: 150 }}>
                            Original
                            <Slider
                                min={0}
                                max={0.999}
                                step={0.001}
                                value={props.volume1}
                                onChange={(_e, newValue) => props.onVolume1Change(newValue as number)}
                            />
                        </Box>
                        {props.video2Available && (
                            <Box component={'div'}>
                                Masked
                                <Slider
                                    min={0}
                                    max={0.999}
                                    step={0.001}
                                    value={props.volume2}
                                    onChange={(_e, newValue) => props.onVolume2Change(newValue as number)}
                                />
                            </Box>
                        )}
                    </Box>
                </Menu>
            </Box>
        </Box>
    );
};

export default ControlBar;
