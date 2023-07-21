import {Card, CardContent, CardMedia, IconButton, Typography} from "@mui/material";
import Config from "../../../config";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import {ResultVideo} from "../../../state/types/ResultVideo";
import VideoResultMenu from "./VideoResultMenu";
import React, {useState} from "react";

interface VideoResultCardProps {
    resultVideo: ResultVideo;
    selected: boolean;
    onSelect: () => void;
}

const VideoResultCard = (props: VideoResultCardProps) => {
    const [videoResultAnchorEl, setVideoResultAnchorEl] = useState<null|HTMLElement>(null);

    const openVideoResultMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        event.preventDefault();
        event.stopPropagation();
        setVideoResultAnchorEl(event.currentTarget);
    };

    return (<>
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
        <VideoResultMenu
            anchorEl={videoResultAnchorEl}
            onClose={() => setVideoResultAnchorEl(null)}
        />
    </>);
};

export default VideoResultCard;
