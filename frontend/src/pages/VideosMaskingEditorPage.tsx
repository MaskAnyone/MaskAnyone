import React, {useEffect, useRef, useState} from "react";
import {useParams} from "react-router";
import {Box} from "@mui/material";
import {useSelector} from "react-redux";
import Selector from "../state/selector";
import Api from "../api";
import Config from "../config";
import KeycloakAuth from "../keycloakAuth";
import DraggablePoint from "../components/videosMakingEditor/DraggablePoint";

const VideoMaskingEditorPage = () => {
    const videoList = useSelector(Selector.Video.videoList);
    const { videoId } = useParams<{ videoId: string }>();

    const imgRef = useRef<HTMLImageElement>(null);
    const [posePrompts, setPosePrompts] = useState<[number, number, number][][]>([]);
    const [bounds, setBounds] = useState({ left: 0, top: 0, right: 0, bottom: 0 });

    const [dragStartPosition, setDragStartPosition] = useState({ x: 0, y: 0 });

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
            // Set the bounds dynamically based on the image dimensions
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
        const threshold = 1; // Adjust this threshold as needed

        if (deltaX < threshold && deltaY < threshold) {
            // Consider it a click
            const newPoints = [...posePrompts];
            newPoints[poseIndex] = [...newPoints[poseIndex]];
            newPoints[poseIndex][pointIndex] = [
                newPoints[poseIndex][pointIndex][0],
                newPoints[poseIndex][pointIndex][1],
                newPoints[poseIndex][pointIndex][2] ? 0 : 1
            ];
            setPosePrompts(newPoints);
        } else {
            // Consider it a drag
            const newPoints = [...posePrompts];
            newPoints[poseIndex] = [...newPoints[poseIndex]];
            newPoints[poseIndex][pointIndex] = [data.x, data.y, posePrompts[poseIndex][pointIndex][2]];
            setPosePrompts(newPoints);
        }
    };

    const handleRightClickPoint = (e: React.MouseEvent, poseIndex: number, pointIndex: number) => {
        e.preventDefault(); // Prevent the default context menu from appearing
        e.stopPropagation(); // Stop the event from propagating to the image's context menu handler
        const newPoints = [...posePrompts];
        newPoints[poseIndex] = newPoints[poseIndex].filter((_, index) => index !== pointIndex);
        setPosePrompts(newPoints);
    };

    const handleRightClickImage = (e: React.MouseEvent) => {
        e.preventDefault(); // Prevent the default context menu from appearing
        if (imgRef.current) {
            const rect = imgRef.current.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            let closestPoseIndex = 0;
            let minDistance = Infinity;

            // Iterate through each pose and find the closest point
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

            // Add the new point to the closest pose
            newPoints[closestPoseIndex] = [...newPoints[closestPoseIndex], [x, y, 1]];

            setPosePrompts(newPoints);
        }
    };

    if (!videoId && videoList.length > 0) {
        return null;
    }

    return (
        <Box
            component="div"
            style={{ position: 'relative', display: 'inline-block' }}
            onContextMenu={handleRightClickImage}
        >
            {videoId && (
                <img
                    ref={imgRef}
                    src={`${Config.api.baseUrl}/videos/${videoId}/first-frame?token=${KeycloakAuth.getToken()}`}
                    alt="Video Frame"
                    style={{ display: 'block' }}
                />
            )}
            {posePrompts.map((pose, poseIndex) => (
                pose.map((point, pointIndex) => (
                    <DraggablePoint
                        key={`${poseIndex}-${pointIndex}`}
                        position={{ x: point[0], y: point[1] }}
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
