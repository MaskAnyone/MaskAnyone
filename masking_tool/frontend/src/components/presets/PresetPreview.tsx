import {Box, Card, CardContent, CardMedia, IconButton, Typography} from "@mui/material";
import {Preset} from "../../state/types/Preset";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import React, {useState} from "react";
import PresetPreviewMenu from "./PresetPreviewMenu";

const styles = {
    card: {
        width: 320,
        height: 170,
    },
    description: {
        paddingTop: 1,
        display: '-webkit-box',
        WebkitLineClamp: 6,
        WebkitBoxOrient: 'vertical',
        overflow: 'hidden',
    },
};

interface PresetPreviewProps {
    preset: Preset;
}

const PresetPreview = (props: PresetPreviewProps) => {
    const [presetPreviewAnchorEl, setPresetPreviewAnchorEl] = useState<null|HTMLElement>(null);

    const openPresetPreviewMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        event.preventDefault();
        event.stopPropagation();
        setPresetPreviewAnchorEl(event.currentTarget);
    };

    return (<>
        <Card sx={styles.card}>
            <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', position: 'relative' }}>
                <CardContent sx={{ width: 160 }}>
                    <Typography variant={'body1'} component="div" fontWeight={'bold'}>
                        {props.preset.name}
                    </Typography>
                    <Typography color={'text.secondary'} fontSize={12} component="div" sx={styles.description}>
                        {props.preset.description}
                        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
                    </Typography>
                </CardContent>
                <CardMedia
                    component={'img'}
                    image={'https://picsum.photos/150/150'}
                    sx={{ width: 160, height: 170 }}
                />
                <IconButton sx={{ position: 'absolute', top: 4, right: 0 }} onClick={openPresetPreviewMenu}>
                    <MoreVertIcon />
                </IconButton>
            </Box>
        </Card>
        <PresetPreviewMenu
            anchorEl={presetPreviewAnchorEl}
            onClose={() => setPresetPreviewAnchorEl(null)}
        />
    </>);
};

export default PresetPreview;
