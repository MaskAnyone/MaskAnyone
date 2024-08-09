import React from 'react';
import Draggable, {DraggableEventHandler} from 'react-draggable';
import { Box, Typography } from '@mui/material';

interface DraggablePointProps {
    position: { x: number, y: number };
    onStart: DraggableEventHandler;
    onStop: DraggableEventHandler;
    onContextMenu: (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => void;
    bounds: { left: number, top: number, right: number, bottom: number };
    isActive: boolean;
    pointLabel: string;
    promptNumber: number;
}

const DraggablePoint = (props: DraggablePointProps) => {
    const pointStyles = {
        pointContainer: {
            position: 'absolute',
            top: -5,
            left: -5,
            cursor: 'pointer',
            textAlign: 'center',
        },
        point: {
            width: '10px',
            height: '10px',
            backgroundColor: props.isActive ? 'green' : 'red',
            borderRadius: '50%',
            fontSize: '9px',
            color: 'white'
        },
        label: {
            fontSize: '8px',
            color: 'white',
            marginTop: '2px',
            whiteSpace: 'nowrap',
            textShadow: '1px 1px 2px black',
            backgroundColor: 'rgba(0, 0, 0, 0.5)',
            padding: '1px 3px',
            borderRadius: '3px',
        }
    };

    return (
        <Draggable
            position={props.position}
            onStart={props.onStart}
            onStop={props.onStop}
            bounds={props.bounds}
        >
            <Box component={'div'} sx={pointStyles.pointContainer} onContextMenu={props.onContextMenu}>
                <Box component={'div'} sx={pointStyles.point}>
                    {props.promptNumber}
                </Box>
                <Typography sx={pointStyles.label}>
                    {props.pointLabel}
                </Typography>
            </Box>
        </Draggable>
    );
};

export default DraggablePoint;
