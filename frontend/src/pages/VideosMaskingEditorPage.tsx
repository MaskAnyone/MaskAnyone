import React, {useEffect, useRef, useState} from "react";
import {useParams} from "react-router";
import {Box} from "@mui/material";
import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import Api from "../api";
import Config from "../config";
import KeycloakAuth from "../keycloakAuth";
import DraggablePoint from "../components/videosMakingEditor/DraggablePoint";
import Command from "../state/actions/command";
import {v4 as uuidv4} from "uuid";

const VideoMaskingEditorPage = () => {
    const dispatch = useDispatch();
    const videoList = useSelector(Selector.Video.videoList);
    const { videoId } = useParams<{ videoId: string }>();

    const imgRef = useRef<HTMLImageElement>(null);
    const [posePrompts, setPosePrompts] = useState<[number, number, number][][]>([]);
    const [bounds, setBounds] = useState({ left: 0, top: 0, right: 0, bottom: 0 });
    const [dragStartPosition, setDragStartPosition] = useState({ x: 0, y: 0 });
    const [segmentationImageUrl, setSegmentationImageUrl] = useState<string | null>(null);

    useEffect(() => {
        if (!videoId) {
            return;
        }

        Api.fetchPosePrompt(videoId).then(posePrompts => {
            setPosePrompts(posePrompts);
        });
    }, [videoId]);

    useEffect(() => {
        if (imgRef.current) {
            imgRef.current.onload = () => {
                const imgWidth = imgRef.current!.offsetWidth;
                const imgHeight = imgRef.current!.offsetHeight;
                setBounds({
                    left: 0,
                    top: 0,
                    right: imgWidth,
                    bottom: imgHeight,
                });
            };
        }
    }, [imgRef.current]);

    const handleDragStart = (e: any, data: any) => {
        setDragStartPosition({ x: data.x, y: data.y });
    };

    const handleDragStop = (poseIndex: number, pointIndex: number, e: any, data: any) => {
        const deltaX = Math.abs(data.x - dragStartPosition.x);
        const deltaY = Math.abs(data.y - dragStartPosition.y);
        const threshold = 1;

        if (deltaX < threshold && deltaY < threshold) {
            const newPoints = [...posePrompts];
            newPoints[poseIndex] = [...newPoints[poseIndex]];
            newPoints[poseIndex][pointIndex] = [
                newPoints[poseIndex][pointIndex][0],
                newPoints[poseIndex][pointIndex][1],
                newPoints[poseIndex][pointIndex][2] ? 0 : 1
            ];
            setPosePrompts(newPoints);
        } else {
            const newPoints = [...posePrompts];
            newPoints[poseIndex] = [...newPoints[poseIndex]];
            newPoints[poseIndex][pointIndex] = [data.x, data.y, posePrompts[poseIndex][pointIndex][2]];
            setPosePrompts(newPoints);
        }
    };

    const handleRightClickPoint = (e: React.MouseEvent, poseIndex: number, pointIndex: number) => {
        e.preventDefault();
        e.stopPropagation();
        const newPoints = [...posePrompts];
        newPoints[poseIndex] = newPoints[poseIndex].filter((_, index) => index !== pointIndex);
        setPosePrompts(newPoints);
    };

    const handleRightClickImage = (e: React.MouseEvent) => {
        e.preventDefault();
        if (imgRef.current) {
            const rect = imgRef.current.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            let closestPoseIndex = 0;
            let minDistance = Infinity;

            posePrompts.forEach((pose, poseIndex) => {
                pose.forEach(point => {
                    const distance = Math.sqrt(Math.pow(point[0] - x, 2) + Math.pow(point[1] - y, 2));
                    if (distance < minDistance) {
                        minDistance = distance;
                        closestPoseIndex = poseIndex;
                    }
                });
            });

            const newPoints = [...posePrompts];
            newPoints[closestPoseIndex] = [...newPoints[closestPoseIndex], [x, y, 1]];
            setPosePrompts(newPoints);
        }
    };

    if (!videoId && videoList.length > 0) {
        return null;
    }

    const maskVideo = () => {
        dispatch(Command.Video.maskVideo({
            id: uuidv4(),
            type: 'sam2_masking',
            videoIds: [videoId!],
            resultVideoId: uuidv4(),
            runData: {
                videoMasking: {
                    posePrompts,
                    overlayStrategies: ['mp_face', 'mp_pose']
                } as any,
                voiceMasking: {
                    strategy: 'remove',
                },
            },
        }));
    };

    const segmentPrompt = () => {
        Api.fetchPosePromptSegmentation(videoId!, posePrompts).then((segmentationImage) => {
            // Create a Blob from the binary data
            const blob = new Blob([segmentationImage], { type: 'image/jpeg' }); // Adjust the MIME type if needed
            // Create a URL for the Blob
            const imageUrl = URL.createObjectURL(blob);
            // Set the image URL in state
            setSegmentationImageUrl(imageUrl);
        });
    };

    return (
        <Box
            component="div"
            style={{position: 'relative', display: 'inline-block'}}
            onContextMenu={handleRightClickImage}
        >
            <button onClick={maskVideo}>test</button>
            <button onClick={segmentPrompt}>segment</button>
            {videoId && (
                <img
                    ref={imgRef}
                    src={segmentationImageUrl || `${Config.api.baseUrl}/videos/${videoId}/first-frame?token=${KeycloakAuth.getToken()}`}
                    alt="Video Frame"
                    style={{display: 'block'}}
                />
            )}
            {posePrompts.map((pose, poseIndex) => (
                pose.map((point, pointIndex) => (
                    <DraggablePoint
                        key={`${poseIndex}-${pointIndex}`}
                        position={{x: point[0], y: point[1]}}
                        onStart={handleDragStart}
                        onStop={(e, data) => handleDragStop(poseIndex, pointIndex, e, data)}
                        onContextMenu={(e) => handleRightClickPoint(e, poseIndex, pointIndex)}
                        bounds={bounds}
                        isActive={!!point[2]}
                        pointLabel={`(${Math.round(point[0])}, ${Math.round(point[1])})`}
                        promptNumber={poseIndex + 1}
                    />
                ))
            ))}
        </Box>
    );
};

export default VideoMaskingEditorPage;
