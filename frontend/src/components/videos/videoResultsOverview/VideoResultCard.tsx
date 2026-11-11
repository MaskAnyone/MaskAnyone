import { Card, CardContent, CardMedia, Chip, IconButton, Tooltip, Typography } from "@mui/material";
import Config from "../../../config";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import { ResultVideo } from "../../../state/types/ResultVideo";
import React, { useEffect, useState } from "react";
import KeycloakAuth from "../../../keycloakAuth";
import Api from "../../../api";

interface VideoResultCardProps {
    resultVideo: ResultVideo;
    selected: boolean;
    onSelect: () => void;
    onOpenMenu: (element: HTMLElement, resultVideoId: string) => void;
}

interface QaSummary {
    coverage_pct: number;
    suspect_frame_count: number;
    missing_mask_frames: number;
    uncovered_keypoint_frames: number;
    verdict: 'green' | 'amber' | 'red';
}

const VERDICT_STYLES: Record<QaSummary['verdict'], { color: 'success' | 'warning' | 'error'; label: (s: QaSummary) => string }> = {
    green: { color: 'success', label: () => '✓ mask ok' },
    amber: { color: 'warning', label: (s) => `⚠ ${s.suspect_frame_count} suspect` },
    red:   { color: 'error',   label: (s) => `✗ ${s.uncovered_keypoint_frames} leak` },
};

const VideoResultCard = (props: VideoResultCardProps) => {
    const [qaSummary, setQaSummary] = useState<QaSummary | null>(null);

    useEffect(() => {
        let cancelled = false;
        Api.fetchResultQa(props.resultVideo.originalVideoId, props.resultVideo.videoResultId)
            .then((qa) => {
                if (!cancelled && qa?.summary) setQaSummary(qa.summary);
            })
            .catch(() => { /* QA is advisory — silent failure is fine */ });
        return () => { cancelled = true; };
    }, [props.resultVideo.originalVideoId, props.resultVideo.videoResultId]);

    const openVideoResultMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        event.preventDefault();
        event.stopPropagation();
        props.onOpenMenu(event.currentTarget, props.resultVideo.videoResultId);
    };

    const lookupPreviewForResult = () => {
        return `${Config.api.baseUrl}/videos/${props.resultVideo.originalVideoId}/results/${props.resultVideo.videoResultId}/preview?token=` + KeycloakAuth.getToken();
    }

    const resultVideo = props.resultVideo;
    const name = resultVideo.name;

    const verdict = qaSummary ? VERDICT_STYLES[qaSummary.verdict] : null;
    const tooltipText = qaSummary
        ? `Mask coverage ${qaSummary.coverage_pct}% — ${qaSummary.suspect_frame_count} suspect frame(s): ${qaSummary.missing_mask_frames} missing, ${qaSummary.uncovered_keypoint_frames} uncovered keypoint`
        : '';

    return (
        <Card
            variant={'outlined'}
            sx={(theme) => ({ width: '250px', display: 'inline-block', marginRight: '16px', cursor: 'pointer', '&:hover': { boxShadow: `0 0 13px 0 ${theme.palette.action.focus}` }, '&.selected': { boxShadow: `0 0 13px 0 ${theme.palette.action.selected}` } })}
            className={props.selected ? 'selected' : undefined}
            onClick={props.onSelect}
        >
            <CardMedia
                sx={{ height: 150, position: 'relative' }}
                image={lookupPreviewForResult()}
            >
                {verdict && qaSummary && (
                    <Tooltip title={tooltipText} placement="top">
                        <Chip
                            label={verdict.label(qaSummary)}
                            color={verdict.color}
                            size="small"
                            sx={{
                                position: 'absolute',
                                top: 6,
                                left: 6,
                                height: 20,
                                fontSize: 11,
                                opacity: 0.95,
                                '& .MuiChip-label': { px: 0.75 },
                            }}
                        />
                    </Tooltip>
                )}
            </CardMedia>
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
