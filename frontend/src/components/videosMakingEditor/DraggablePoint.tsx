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
    const isPositive = props.isActive;
    const fillColor = isPositive ? 'green' : 'red';

    const pointStyles = {
        pointContainer: {
            position: 'absolute',
            top: -5,
            left: -5,
            cursor: 'pointer',
            textAlign: 'center',
        },
        point: {
            position: 'relative',
            width: '10px',
            height: '10px',
            backgroundColor: fillColor,
            borderRadius: '50%',
            fontSize: '9px',
            color: 'white',
            // White ring + soft shadow keeps the dot legible against any
            // background — including the green sheet/green shirt case where
            // a bare green positive dot would otherwise vanish.
            boxShadow: '0 0 0 1px white, 0 0 2px rgba(0,0,0,0.6)',
        },
        polarityBadge: {
            // Tiny corner glyph: + for positive (subject), − for negative
            // (background). Doubles up shape + color so polarity reads at a
            // glance even when the dot is the same hue as what's behind it.
            position: 'absolute',
            top: -4,
            right: -4,
            width: '8px',
            height: '8px',
            lineHeight: '8px',
            backgroundColor: 'white',
            color: fillColor,
            borderRadius: '50%',
            fontSize: '9px',
            fontWeight: 'bold',
            textAlign: 'center',
            border: `1px solid ${fillColor}`,
            pointerEvents: 'none',
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
                    <Box component={'div'} sx={pointStyles.polarityBadge}>
                        {isPositive ? '+' : '−'}
                    </Box>
                </Box>
                <Typography sx={pointStyles.label}>
                    {props.pointLabel}
                </Typography>
            </Box>
        </Draggable>
    );
};

export default DraggablePoint;
