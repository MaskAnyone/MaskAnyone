from masking.smoothing import smooth_pose

CONFIDENCE_THRESHOLD = 0.05
SMOOTHING = True

class PosePostprocessor:
    _confidence: float
    _smoothing: bool

    def __init__(self):
        self._confidence = CONFIDENCE_THRESHOLD
        self._smoothing = SMOOTHING

    def postprocess(self, pose_data_dict, overlay_strategies, frame_count, sample_rate, estimation_input_bounding_boxes):
        for obj_id, pose_data in pose_data_dict.items():
            overlay_strategy = overlay_strategies[obj_id - 1]

            if overlay_strategy.startswith('openpose'):
                self._postprocess_openpose(
                    pose_data_dict,
                    frame_count,
                    estimation_input_bounding_boxes,
                    obj_id,
                    pose_data
                )

                if SMOOTHING:
                    pose_keypoint_list = [pose_data['pose_keypoints'] if pose_data is not None else None for pose_data in pose_data_dict[obj_id]]
                    face_keypoint_list = [pose_data['face_keypoints'] if pose_data is not None else None for pose_data in pose_data_dict[obj_id]]

                    smoothed_pose_keypoint_list = smooth_pose(
                        pose_keypoint_list,
                        sample_rate,
                        3,
                        10
                    )

                    smoothed_face_keypoint_list = smooth_pose(
                        face_keypoint_list,
                        sample_rate,
                        2,
                        14
                    )

                    for idx in range(frame_count):
                        if pose_data_dict[obj_id][idx] is None:
                            continue

                        pose_data_dict[obj_id][idx]['pose_keypoints'] = smoothed_pose_keypoint_list[idx]
                        pose_data_dict[obj_id][idx]['face_keypoints'] = smoothed_face_keypoint_list[idx]

            elif overlay_strategy == 'mp_pose':
                self._postprocess_mp_pose(
                    pose_data_dict,
                    frame_count,
                    estimation_input_bounding_boxes,
                    obj_id,
                    pose_data
                )

                if SMOOTHING:
                    # Don't smooth, just interpolate
                    pose_data_dict[obj_id] = smooth_pose(
                        pose_data_dict[obj_id],
                        sample_rate,
                        -1,
                        -1
                    )
            elif overlay_strategy == 'mp_face':
                self._postprocess_mp_face(
                    pose_data_dict,
                    frame_count,
                    estimation_input_bounding_boxes,
                    obj_id,
                    pose_data
                )
            elif overlay_strategy == 'mp_hand':
                self._postprocess_mp_hand(
                    pose_data_dict,
                    frame_count,
                    estimation_input_bounding_boxes,
                    obj_id,
                    pose_data
                )
            elif overlay_strategy == 'mask_anyone_holistic':
                self._postprocess_mask_anyone_holistic(
                    pose_data_dict,
                    frame_count,
                    estimation_input_bounding_boxes,
                    obj_id,
                    pose_data
                )

    def _postprocess_openpose(self, pose_data_dict, frame_count, estimation_input_bounding_boxes, obj_id, pose_data):
        for idx in range(frame_count):
            bbox_start_frames = [frame for frame in estimation_input_bounding_boxes[obj_id].keys() if frame <= idx]

            if len(bbox_start_frames) < 1:
                #print(f'Warning: Could not find relevant start frame for pose postprocessing for index f{idx}')
                #print('Start frames', [frame for frame in estimation_input_bounding_boxes[obj_id].keys()])
                pose_data_dict[obj_id][idx] = None
                continue

            relevant_start_frame = max(bbox_start_frames)

            bbox = estimation_input_bounding_boxes[obj_id][relevant_start_frame]
            xmin, ymin, xmax, ymax = bbox

            current_pose = pose_data[idx]

            if current_pose is None or current_pose['pose_keypoints'] is None:
                pose_data_dict[obj_id][idx] = None
                continue

            adjusted_pose = {
                'pose_keypoints': [],
                'face_keypoints': None,
                'left_hand_keypoints': None,
                'right_hand_keypoints': None
            }

            for keypoint in current_pose['pose_keypoints']:
                if keypoint is not None and (keypoint[0] > 0 or keypoint[1] > 0) and keypoint[2] > self._confidence:
                    # Translate the keypoint back to the original frame coordinates
                    adjusted_keypoint = (keypoint[0] + xmin, keypoint[1] + ymin)
                    adjusted_pose['pose_keypoints'].append(adjusted_keypoint)
                else:
                    adjusted_pose['pose_keypoints'].append(None)

            if current_pose['face_keypoints'] is not None:
                adjusted_pose['face_keypoints'] = []

                for keypoint in current_pose['face_keypoints']:
                    if keypoint is not None and (keypoint[0] > 0 or keypoint[1] > 0) and keypoint[2] > self._confidence:
                        # Translate the keypoint back to the original frame coordinates
                        adjusted_keypoint = (keypoint[0] + xmin, keypoint[1] + ymin)
                        adjusted_pose['face_keypoints'].append(adjusted_keypoint)
                    else:
                        adjusted_pose['face_keypoints'].append(None)

            if current_pose['left_hand_keypoints'] is not None:
                adjusted_pose['left_hand_keypoints'] = []

                for keypoint in current_pose['left_hand_keypoints']:
                    if keypoint is not None and (keypoint[0] > 0 or keypoint[1] > 0) and keypoint[2] > self._confidence:
                        # Translate the keypoint back to the original frame coordinates
                        adjusted_keypoint = (keypoint[0] + xmin, keypoint[1] + ymin)
                        adjusted_pose['left_hand_keypoints'].append(adjusted_keypoint)
                    else:
                        adjusted_pose['left_hand_keypoints'].append(None)

            if current_pose['right_hand_keypoints'] is not None:
                adjusted_pose['right_hand_keypoints'] = []

                for keypoint in current_pose['right_hand_keypoints']:
                    if keypoint is not None and (keypoint[0] > 0 or keypoint[1] > 0) and keypoint[2] > self._confidence:
                        # Translate the keypoint back to the original frame coordinates
                        adjusted_keypoint = (keypoint[0] + xmin, keypoint[1] + ymin)
                        adjusted_pose['right_hand_keypoints'].append(adjusted_keypoint)
                    else:
                        adjusted_pose['right_hand_keypoints'].append(None)

            pose_data_dict[obj_id][idx] = adjusted_pose

    def _postprocess_mp_pose(self, pose_data_dict, frame_count, estimation_input_bounding_boxes, obj_id, pose_data):
        for idx in range(frame_count):
            bbox_start_frames = [frame for frame in estimation_input_bounding_boxes[obj_id].keys() if frame <= idx]

            if len(bbox_start_frames) < 1:
                #print(f'Warning: Could not find relevant start frame for pose postprocessing for index f{idx}')
                #print('Start frames', [frame for frame in estimation_input_bounding_boxes[obj_id].keys()])
                pose_data_dict[obj_id][idx] = None
                continue

            relevant_start_frame = max(bbox_start_frames)

            bbox = estimation_input_bounding_boxes[obj_id][relevant_start_frame]
            xmin, ymin, xmax, ymax = bbox

            current_pose = pose_data[idx]

            if current_pose is None:
                pose_data_dict[obj_id][idx] = None
                continue

            adjusted_pose = []
            for keypoint in current_pose:
                if keypoint is not None and (keypoint.x > 0 or keypoint.y > 0) and keypoint.visibility > self._confidence:
                    # Translate the keypoint back to the original frame coordinates
                    adjusted_keypoint = (keypoint.x * (xmax - xmin) + xmin, keypoint.y * (ymax - ymin) + ymin)
                    adjusted_pose.append(adjusted_keypoint)
                else:
                    adjusted_pose.append(None)

            pose_data_dict[obj_id][idx] = adjusted_pose

    def _postprocess_mp_face(self, pose_data_dict, frame_count, estimation_input_bounding_boxes, obj_id, pose_data):
        for idx in range(frame_count):
            relevant_start_frame = max(
                frame for frame in estimation_input_bounding_boxes[obj_id].keys() if frame <= idx)

            bbox = estimation_input_bounding_boxes[obj_id][relevant_start_frame]
            xmin, ymin, xmax, ymax = bbox

            current_face = pose_data[idx]

            adjusted_face = []
            for keypoint in current_face:
                if keypoint is not None and (keypoint.x > 0 or keypoint.y > 0):
                    # Translate the keypoint back to the original frame coordinates
                    adjusted_keypoint = (keypoint.x * (xmax - xmin) + xmin, keypoint.y * (ymax - ymin) + ymin)
                    adjusted_face.append(adjusted_keypoint)
                else:
                    adjusted_face.append(None)

            pose_data_dict[obj_id][idx] = adjusted_face

    def _postprocess_mp_hand(self, pose_data_dict, frame_count, estimation_input_bounding_boxes, obj_id, pose_data):
        for idx in range(frame_count):
            relevant_start_frame = max(
                frame for frame in estimation_input_bounding_boxes[obj_id].keys() if frame <= idx)

            bbox = estimation_input_bounding_boxes[obj_id][relevant_start_frame]
            xmin, ymin, xmax, ymax = bbox

            current_hand = pose_data[idx]

            if current_hand is None:
                continue

            adjusted_hand = []
            for keypoint in current_hand:
                if keypoint is not None and (keypoint.x > 0 or keypoint.y > 0):
                    # Translate the keypoint back to the original frame coordinates
                    adjusted_keypoint = (keypoint.x * (xmax - xmin) + xmin, keypoint.y * (ymax - ymin) + ymin)
                    adjusted_hand.append(adjusted_keypoint)
                else:
                    adjusted_hand.append(None)

            pose_data_dict[obj_id][idx] = adjusted_hand
