import React from 'react';

interface TimerDisplayProps {
    timeInSeconds: number;
}

const TimerDisplay = (props: TimerDisplayProps) => {
    const minutes = Math.floor(props.timeInSeconds / 60);
    const seconds = Math.floor(props.timeInSeconds % 60);
    const tenthsOfSeconds = Math.floor((props.timeInSeconds % 1) * 10);

    const formatNumber = (num: number) => {
        return num.toString().padStart(2, '0');
    };

    return (
        <div style={{ display: 'flex', alignItems: 'center' }}>
            <div style={{ fontSize: '1.5rem' }}>
                {minutes}:{formatNumber(seconds)}
            </div>
            <div style={{ fontSize: '0.8rem', marginTop: '-0.75rem', marginLeft: '0.25rem' }}>
                {tenthsOfSeconds}
            </div>
        </div>
    );
};

export default TimerDisplay;
