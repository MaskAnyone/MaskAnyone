import React from 'react';
import {Chip, ChipProps} from '@mui/material';
import sha256 from 'crypto-js/sha256';

const tagToColor = (tag: string) => {
    const [val1, val2, val3] = sha256(tag).words.map(Math.abs);
    return `rgba(${val1 % 255}, ${val2 % 255}, ${val3 % 255}, 0.7)`;
};

interface FileTagProps extends ChipProps {
    label: string;
}

const FileTag = (props: FileTagProps) => {
    return (
        <Chip
            size={'small'}
            variant={'outlined'}
            style={{ backgroundColor: tagToColor(props.label) }}
            {...props}
        />
    );
};

export default FileTag;
