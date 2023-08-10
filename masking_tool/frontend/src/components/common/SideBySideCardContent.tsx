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
            <Typography variant={'body1'} component="div" fontWeight={'bold'} sx={{ lineHeight: "0.1" }}>
                {props.selectable && (
                    <Radio checked={props.selected} onChange={props.onSelect} />
                )}
                {props.checkable && (
                    <Checkbox checked={props.selected} onChange={props.onSelect} />
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
