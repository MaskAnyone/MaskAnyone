import {Box, Card, CardContent, CardMedia, IconButton, Typography} from "@mui/material";
import {Preset} from "../../state/types/Preset";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import React from "react";

const styles = {
    card: {
        width: 320,
        height: 170,
    },
    description: {
        paddingTop: 0.75,
        display: '-webkit-box',
        WebkitLineClamp: 6,
        WebkitBoxOrient: 'vertical',
        overflow: 'hidden',
    },
};

interface PresetPreviewProps {
    preset: Preset;
    onOpenMenu: (element: HTMLElement) => void;
}

const PresetPreview = (props: PresetPreviewProps) => {
    const openPresetPreviewMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        event.preventDefault();
        event.stopPropagation();
        props.onOpenMenu(event.currentTarget);
    };

    return (
        <Card sx={styles.card}>
            <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', position: 'relative' }}>
                <CardContent sx={{ width: 160 }}>
                    <Typography variant={'body1'} component="div" fontWeight={'bold'}>
                        {props.preset.name}
                    </Typography>
                    <Typography color={'text.secondary'} fontSize={12} component="div" sx={styles.description}>
                        {props.preset.description}
                    </Typography>
                </CardContent>
                <CardMedia
                    component={'img'}
                    image={'https://picsum.photos/150/150'}
                    sx={{ width: 160, height: 170 }}
                />
                <IconButton sx={{ position: 'absolute', top: 4, right: 0 }} onClick={openPresetPreviewMenu}>
                    <MoreVertIcon sx={{ color: 'white', mixBlendMode: 'difference'}} />
                </IconButton>
            </Box>
        </Card>
    );
};

export default PresetPreview;
