import React, {Fragment, useCallback, useEffect, useMemo, useRef, useState} from "react";
import {useParams} from "react-router";
import {Box, Button, Divider, IconButton, InputLabel, MenuItem, Select, Slider, TextField} from "@mui/material";
import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import Api from "../api";
import Config from "../config";
import KeycloakAuth from "../keycloakAuth";
import DraggablePoint from "../components/videosMakingEditor/DraggablePoint";
import Command from "../state/actions/command";
import {v4 as uuidv4} from "uuid";
import HighlightOffIcon from '@mui/icons-material/HighlightOff';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import ShieldLogoIcon from "../components/common/ShieldLogoIcon";
import { debounce } from 'lodash';
import { ReduxState } from "../state/reducer";

const VideoMaskingEditorPage = () => {
    const dispatch = useDispatch();
    const videoList = useSelector(Selector.Video.videoList);
    const { videoId, resultVideoId } = useParams<{ videoId: string, resultVideoId?: string }>();

    const imgRef = useRef<HTMLImageElement>(null);
    const [currentFrame, setCurrentFrame] = useState<number>(0);
    const [debouncedCurrentFrame, setDebouncedCurrentFrame] = useState<number>(currentFrame);
    const [posePrompts, setPosePrompts] = useState<[number, number, number][][]>([]);
    const [hidingStrategies, setHidingStrategies] = useState<string[]>([]);
    const [overlayStrategies, setOverlayStrategories] = useState<string[]>([]);
    const [bounds, setBounds] = useState({ left: 0, top: 0, right: 0, bottom: 0 });
    const [dragStartPosition, setDragStartPosition] = useState({ x: 0, y: 0 });
    const [segmentationImageUrl, setSegmentationImageUrl] = useState<string | null>(null);
    const [videoPosePrompts, setVideoPosePrompts] = useState<Record<string, [number, number, number][][]>>({});

    const resultVideoLists = useSelector(Selector.Video.resultVideoLists);
    const resultVideos = resultVideoLists[videoId || ''] || [];
    const activeResultVideo = resultVideos.find(resultVideo => resultVideo.videoResultId === resultVideoId);
    const selectJobById = Selector.Job.makeSelectJobById();
    const resultVideoJob = useSelector((state: ReduxState) => selectJobById(state, activeResultVideo?.jobId || ''));

    useEffect(() => {
        if (!videoId) {
            return;
        }

        if (resultVideoId) {
            if (!resultVideoJob) {
                dispatch(Command.Video.fetchResultsList({ videoId }));
                return;
            }

            setVideoPosePrompts((resultVideoJob.data as any)['videoMasking']['posePrompts']);
            setPosePrompts((resultVideoJob.data as any)['videoMasking']['posePrompts'][0]);
            setOverlayStrategories((resultVideoJob.data as any)['videoMasking']['overlayStrategies']);
            setHidingStrategies((resultVideoJob.data as any)['videoMasking']['hidingStrategies'] || []);
        } else {
            Api.fetchPosePrompt(videoId, currentFrame).then(posePrompts => {
                setPosePrompts(posePrompts);
                setOverlayStrategories(posePrompts.map((_: any) => 'mp_pose'));
                setHidingStrategies(posePrompts.map((_: any) => 'solid_fill'));
            });
        }
    }, [videoId, resultVideoId, Boolean(resultVideoJob)]);

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

    const targetCount = useMemo(() => {
        const posePromptsTargets = posePrompts.length;
        const videoPosePromptsTargets = Object.values(videoPosePrompts).reduce(
            (currentMax, framePosePrompt) => Math.max(currentMax, framePosePrompt.length),
            0,
        );

        return Math.max(posePromptsTargets, videoPosePromptsTargets);
    }, [posePrompts, videoPosePrompts]);

    const debouncedSetCurrentFrame = useCallback(
        debounce((frame) => {
            setDebouncedCurrentFrame(frame);
        }, 500),
        [],
    );

    useEffect(() => {
        debouncedSetCurrentFrame(currentFrame);
    }, [currentFrame, debouncedSetCurrentFrame]);

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
            newPoints[poseIndex][pointIndex] = [
                Math.round(data.x), 
                Math.round(data.y), 
                posePrompts[poseIndex][pointIndex][2],
            ];
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
            const x = Math.round(e.clientX - rect.left);
            const y = Math.round(e.clientY - rect.top);

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

    const addNewTarget = () => {
        const updatedPosePrompts = [
            ...posePrompts,
            ...Array(Math.max(0, targetCount - posePrompts.length)).fill([]),
        ];

        const updatedOverlayStrategies = [
            ...overlayStrategies,
            ...Array(Math.max(0, targetCount - overlayStrategies.length)).fill('none'),
        ];

        const updatedHidingStrategies = [
            ...hidingStrategies,
            ...Array(Math.max(0, targetCount - hidingStrategies.length)).fill('none'),
        ];

        // Add the actual new target
        setPosePrompts([...updatedPosePrompts, [[100, 100, 1]]]);
        setOverlayStrategories([...updatedOverlayStrategies, 'none']);
        setHidingStrategies([...updatedHidingStrategies, 'none']);
    };

    const addTargetPoint = (targetIndex: number) => {
        const newPosePrompts = [...posePrompts];

        while (newPosePrompts.length <= targetIndex) {
            newPosePrompts.push([]);
        }

        newPosePrompts[targetIndex].push([100, 100, 1]);
        setPosePrompts(newPosePrompts);
    };

    const removeTarget = (targetIndex: number) => {
        const newPosePrompts = [...posePrompts];
        newPosePrompts.splice(targetIndex, 1);
        setPosePrompts(newPosePrompts);
    };

    const addPrompt = () => {
        setVideoPosePrompts({
            ...videoPosePrompts,
            [currentFrame]: posePrompts,
        });
        setPosePrompts(Array.from({ length: targetCount }, () => []));
        setSegmentationImageUrl(null);
    };

    if (!videoId && videoList.length > 0) {
        return null;
    }

    const video = videoList.find(videoListItem => videoListItem.id === videoId)!;
    const frameCount = video?.videoInfo.frameCount || 0;

    const maskVideo = () => {
        if (!posePrompts.some(prompt => prompt.length > 0) && Object.entries(videoPosePrompts).length < 1) {
            dispatch(Command.Notification.enqueueNotification({
                severity: 'error',
                message: 'You need to specify a pose prompt to trigger the masking process.',
            }));

            return;
        }

        dispatch(Command.Video.maskVideo({
            id: uuidv4(),
            type: 'sam2_masking',
            videoIds: [videoId!],
            resultVideoId: uuidv4(),
            runData: {
                videoMasking: {
                    posePrompts: posePrompts.some(prompt => prompt.length > 0) 
                        ? { ...videoPosePrompts, [currentFrame]: posePrompts } 
                        : videoPosePrompts,
                    overlayStrategies,
                    hidingStrategies,
                } as any,
                voiceMasking: {
                    strategy: 'remove',
                },
            },
        }));
    };

    const segmentPrompt = () => {
        if (!posePrompts.some(prompt => prompt.length > 0)) {
            dispatch(Command.Notification.enqueueNotification({
                severity: 'error',
                message: 'You need to specify a pose prompt to preview the segmentation.',
            }));

            return;
        }

        Api.fetchPosePromptSegmentation(videoId!, currentFrame, posePrompts).then((segmentationImage) => {
            // Create a Blob from the binary data
            const blob = new Blob([segmentationImage], { type: 'image/jpeg' }); // Adjust the MIME type if needed
            // Create a URL for the Blob
            const imageUrl = URL.createObjectURL(blob);
            // Set the image URL in state
            setSegmentationImageUrl(imageUrl);
        });
    };

    const updateOverlayStrategy = (newValue: string, index: number) => {
        const newOverlayStrategies = [...overlayStrategies];
        newOverlayStrategies[index] = newValue;
        setOverlayStrategories(newOverlayStrategies);
    };

    const updateHidingStrategy = (newValue: string, index: number) => {
        const newHidingStrategies = [...hidingStrategies];
        newHidingStrategies[index] = newValue;
        setHidingStrategies(newHidingStrategies);
    };

    return (
        <Box component="div" sx={{ display: 'flex' }}>
            <Box component='div' sx={{ width: 320 }}>
                <Button onClick={maskVideo} variant={'contained'} color={'secondary'} startIcon={<ShieldLogoIcon />}>Mask</Button>
                <Button onClick={segmentPrompt} variant={'contained'} color={'primary'} sx={{ marginLeft: 1, marginRight: 1 }}>Test Prompt</Button>

                <Divider sx={{ marginTop: 2 }} />

                {Array.from({ length: targetCount }, (_, ti) => ti).map((_, index) => (
                    <Box component='div' sx={{ marginTop: 1 }} key={index}>
                        <div>
                            Target {index + 1}
                            <IconButton><HighlightOffIcon onClick={() => removeTarget(index)} /></IconButton>
                            <IconButton><AddCircleOutlineIcon onClick={() => addTargetPoint(index)} /></IconButton>
                        </div>

                        <Select 
                            value={overlayStrategies[index] || ''}
                            onChange={e => updateOverlayStrategy(e.target.value as string, index)}
                            size='small'
                        >
                            <MenuItem value={'none'}>No Overlay</MenuItem>
                            <MenuItem value={'mp_pose'}>MediaPipe Pose</MenuItem>
                            <MenuItem value={'mp_face'}>MediaPipe Face</MenuItem>
                            <MenuItem value={'mp_hand'}>MediaPipe Hands</MenuItem>
                            <MenuItem value={'openpose'}>Openpose</MenuItem>
                            <MenuItem value={'openpose_body25b'}>Openpose (BODY_25B)</MenuItem>
                            <MenuItem value={'openpose_face'}>Openpose + Face</MenuItem>
                            <MenuItem value={'openpose_body_135'}>Openpose (BODY_135)</MenuItem>
                        </Select>
                        <br />
                        <Select 
                            value={hidingStrategies[index] || ''}
                            onChange={e => updateHidingStrategy(e.target.value as string, index)}
                            size='small'
                        >
                            <MenuItem value={'none'}>No Hiding</MenuItem>
                            <MenuItem value={'solid_fill'}>Solid Fill</MenuItem>
                            <MenuItem value={'transparent_fill'}>Transparent Fill</MenuItem>
                            <MenuItem value={'blurring'}>Blurring</MenuItem>
                            <MenuItem value={'pixelation'}>Pixelation</MenuItem>
                            <MenuItem value={'contours'}>Contours</MenuItem>
                        </Select>
                    </Box>
                ))}

                <Box component='div' sx={{ marginTop: 3}}>
                    <Button variant={'contained'} onClick={addNewTarget}>Add New Target</Button>
                </Box>

                <Divider sx={{ marginTop: 2 }} />

                <Box component='div' sx={{ marginTop: 2}}>
                    <Button variant={'contained'} onClick={addPrompt}>Prompt Another Frame</Button>
                </Box>

                {Object.entries(videoPosePrompts).map(([frameIndex, framePosePrompts]) => (
                    <Box component='div' key={frameIndex}>
                        <strong>Frame {frameIndex}:</strong><br />
                        {framePosePrompts.map((framePosePrompt, targetIndex) => <Fragment key={targetIndex}>T{targetIndex + 1}: {JSON.stringify(framePosePrompt)}<br /></Fragment>)}
                    </Box>
                ))}
            </Box>
            <Box component="div" sx={{ width: 'calc(100% - 320px)', overflow: 'auto' }}>
                <Box component="div" sx={{ maxHeight: 'calc(100vh - 120px)', overflow: 'auto' }}>
                    <Box 
                        component="div" 
                        style={{position: 'relative', display: 'inline-block'}}
                        onContextMenu={handleRightClickImage}
                    >
                        {videoId && (
                            <img
                                ref={imgRef}
                                src={segmentationImageUrl || `${Config.api.baseUrl}/videos/${videoId}/frames/${debouncedCurrentFrame}?token=${KeycloakAuth.getToken()}`}
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
                </Box>
                {Boolean(videoPosePrompts[0]) && (
                    <Slider 
                        min={0} 
                        max={frameCount - 1} 
                        value={currentFrame} 
                        onChange={(_, newFrame: number | number[]) => setCurrentFrame(newFrame as number)} 
                        sx={{ margin: '0 12px' }}
                    />
                )}
            </Box>
        </Box>
    );
};

export default VideoMaskingEditorPage;
