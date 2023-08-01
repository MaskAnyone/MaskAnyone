import {Card, CardContent, CardMedia, IconButton, Typography} from "@mui/material";
import Config from "../../../config";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import {ResultVideo} from "../../../state/types/ResultVideo";
import React from "react";

interface VideoResultCardProps {
    resultVideo: ResultVideo;
    selected: boolean;
    onSelect: () => void;
    onOpenMenu: (element: HTMLElement) => void;
}

const VideoResultCard = (props: VideoResultCardProps) => {
    const openVideoResultMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        event.preventDefault();
        event.stopPropagation();
        props.onOpenMenu(event.currentTarget);
    };

    return (
        <Card
            variant={'outlined'}
            sx={{ width: '250px', display: 'inline-block', marginRight: '16px', cursor: 'pointer', '&:hover': { boxShadow: '0 0 13px 0 #c8c8c8' }, '&.selected': { boxShadow: '0 0 13px 0 #777'}}}
            className={props.selected ? 'selected' : undefined}
            onClick={props.onSelect}
        >
            <CardMedia
                sx={{ height: 150 }}
                image={`${Config.api.baseUrl}/videos/${props.resultVideo.videoId}/results/${props.resultVideo.id}/preview`}
            />
            <CardContent sx={{ position: 'relative' }}>
                <Typography gutterBottom variant="h6" component="div">
                    {props.resultVideo.name}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                    {props.resultVideo.createdAt.toLocaleDateString()}
                </Typography>
                <IconButton sx={{ position: 'absolute', top: 4, right: 0 }} onClick={openVideoResultMenu}>
                    <MoreVertIcon />
                </IconButton>
            </CardContent>
        </Card>
    );
};

export default VideoResultCard;
