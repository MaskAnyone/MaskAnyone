import { CardContent, Checkbox, Radio, Typography } from "@mui/material";
import React from "react";

const styles = {
    description: {
        paddingTop: 0.75,
        display: '-webkit-box',
        WebkitLineClamp: 6,
        WebkitBoxOrient: 'vertical',
        overflow: 'hidden',
    },
    checkbox: {
        padding: 0.5,
        marginTop: -0.5,
        marginLeft: -0.5
    },
    radioButton: {
        padding: 0.5,
        marginTop: -0.5,
        marginLeft: -0.5
    },
    title: {
        display: 'flex',
        alignItems: 'flex-start',
    }
};

interface SideBySideCardContentProps {
    title: string;
    description: string;
    selectable?: boolean;
    checkable?: boolean;
    selected?: boolean;
    onSelect?: () => void;
}

const SideBySideCardContent = (props: SideBySideCardContentProps) => {
    return (
        <CardContent sx={{ width: 160 }}>
            <Typography variant={'body1'} component="div" fontWeight={'bold'} sx={styles.title}>
                {props.selectable && (
                    <Radio checked={props.selected} onChange={props.onSelect} sx={styles.radioButton} />
                )}
                {props.checkable && (
                    <Checkbox checked={props.selected} onChange={props.onSelect}  sx={styles.checkbox} />
                )}
                {props.title}
            </Typography>
            <Typography color={'text.secondary'} fontSize={12} component="div" sx={styles.description}>
                {props.description}
            </Typography>
        </CardContent>
    );
};

export default SideBySideCardContent;
