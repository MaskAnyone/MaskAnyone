import { Card, CardContent, CardMedia, IconButton, Typography } from "@mui/material";
import Config from "../../../config";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import { ResultVideo } from "../../../state/types/ResultVideo";
import React from "react";
import file from "../../../assets/previews/file.png";

interface VideoResultCardProps {
    resultVideo: ResultVideo;
    selected: boolean;
    onSelect: () => void;
    onOpenMenu: (element: HTMLElement, resultVideoId: string) => void;
}

const VideoResultCard = (props: VideoResultCardProps) => {
    const openVideoResultMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        event.preventDefault();
        event.stopPropagation();
        props.onOpenMenu(event.currentTarget, props.resultVideo.videoResultId);
    };

    const lookupPreviewForResult = () => {
        if (props.resultVideo.videoResultExists) {
            return `${Config.api.baseUrl}/videos/${props.resultVideo.originalVideoId}/results/${props.resultVideo.videoResultId}/preview`;
        }

        if (props.resultVideo.blendshapeResultsExists) {
            return '/images/model_extraction/facial_3d_model.jpg';
        }

        if (props.resultVideo.kinematicResultsExists) {
            return '/images/model_extraction/skeleton.png';
        }

        return file;
    }

    const resultVideo = props.resultVideo;
    const name = resultVideo.videoResultExists ? resultVideo.name : "File Result"

    return (
        <Card
            variant={'outlined'}
            sx={{ width: '250px', display: 'inline-block', marginRight: '16px', cursor: 'pointer', '&:hover': { boxShadow: '0 0 13px 0 #c8c8c8' }, '&.selected': { boxShadow: '0 0 13px 0 #777' } }}
            className={props.selected ? 'selected' : undefined}
            onClick={props.onSelect}
        >
            <CardMedia
                sx={{ height: 150 }}
                image={lookupPreviewForResult()}
            />
            <CardContent sx={{ position: 'relative' }}>
                <Typography gutterBottom variant="h6" component="div">
                    {name}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                    {props.resultVideo.createdAt.toLocaleString()}
                </Typography>
                <IconButton sx={{ position: 'absolute', top: 4, right: 0 }} onClick={openVideoResultMenu}>
                    <MoreVertIcon />
                </IconButton>
            </CardContent>
        </Card>
    );
};

export default VideoResultCard;
