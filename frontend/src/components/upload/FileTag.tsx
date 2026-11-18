import React from 'react';
import {Chip, ChipProps} from '@mui/material';
import sha256 from 'crypto-js/sha256';

const tagToColors = (tag: string) => {
    const [val1, val2, val3] = sha256(tag).words.map(Math.abs);
    const r = val1 % 255;
    const g = val2 % 255;
    const b = val3 % 255;
    // Calculate relative luminance to determine text color
    const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    const textColor = luminance > 0.5 ? '#000000' : '#ffffff';
    return {
        backgroundColor: `rgba(${r}, ${g}, ${b}, 0.7)`,
        textColor,
    };
};

interface FileTagProps extends ChipProps {
    label: string;
}

const FileTag = (props: FileTagProps) => {
    const colors = tagToColors(props.label);
    return (
        <Chip
            size={'small'}
            variant={'outlined'}
            style={{ backgroundColor: colors.backgroundColor, color: colors.textColor }}
            {...props}
        />
    );
};

export default FileTag;
