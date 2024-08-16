import numpy as np
from scipy.signal import butter, filtfilt
from scipy.interpolate import interp1d


def butter_it(x, sampling_rate, order, lowpass_cutoff):
    nyquist = sampling_rate / 2
    cutoff = lowpass_cutoff / nyquist  # Normalized frequency
    b, a = butter(order, cutoff, btype='low')
    filtered_x = filtfilt(b, a, x)
    return np.asarray(filtered_x, dtype=np.float64)


def smooth_pose(pose_data, sampling_rate):
    # The butterworth filter will break if we have less than 12 data points
    if len(pose_data) < 12:
        return pose_data

    # sampling_rate should match video framerate
    data_dict = {}

    # Populate data_dict with keypoint data
    for frame_idx, frame_poses in enumerate(pose_data):
        if frame_poses is None:
            # Fill dict with None values to be handled later
            for keypoint_idx in range(len(pose_data[0][0])):  # Assuming pose_data[0][0] is a non-empty pose
                data_dict.setdefault((keypoint_idx, 0), []).append(None)
                data_dict.setdefault((keypoint_idx, 1), []).append(None)
                data_dict.setdefault((keypoint_idx, 2), []).append(None)
            continue

        pose = frame_poses[0]
        for keypoint_idx, keypoint in enumerate(pose):
            if keypoint[0] < 1 and keypoint[1] < 1:
                # Treat (0, 0) as missing data
                data_dict.setdefault((keypoint_idx, 0), []).append(None)
                data_dict.setdefault((keypoint_idx, 1), []).append(None)
                data_dict.setdefault((keypoint_idx, 2), []).append(None)
            else:
                data_dict.setdefault((keypoint_idx, 0), []).append(keypoint[0])
                data_dict.setdefault((keypoint_idx, 1), []).append(keypoint[1])
                data_dict.setdefault((keypoint_idx, 2), []).append(keypoint[2])

    order = 3  # Butterworth filter order
    lowpass_cutoff = 15  # Hz 10 (heavy) to 15 (most movements don't happen in less than 100ms)

    for key in data_dict.keys():
        data = data_dict[key]

        # Interpolate small gaps (<= 3 frames)
        indices = np.arange(len(data))
        valid = np.where(np.array(data) != None)[0]

        if len(valid) > 0:
            f = interp1d(valid, np.array(data)[valid], kind='linear', fill_value="extrapolate")
            interpolated_data = f(indices)
            # Replace None with the interpolated values in data_dict
            data_dict[key] = [interpolated_data[i] if data[i] is None else data[i] for i in range(len(data))]
        else:
            # If no valid points exist, fill with a default value (e.g., 0)
            data_dict[key] = [0 if val is None else val for val in data]

        if len(valid) >= 12:  # Ensure there are enough points for the filter
            data_dict[key] = butter_it(data_dict[key], sampling_rate, order, lowpass_cutoff)
        else:
            print("Warning: Skipping pose smoothing for property because valid point count <12")

        # Apply Butterworth filter
        data_dict[key] = butter_it(data_dict[key], sampling_rate, order, lowpass_cutoff)

    # Reconstruct the pose data from smoothed data_dict
    smoothed_pose_data = []

    for frame_idx in range(len(pose_data)):
        if pose_data[frame_idx] is None:
            smoothed_pose_data.append(None)
            continue

        smoothed_pose = []
        for keypoint_idx in range(len(pose_data[frame_idx][0])):
            smoothed_keypoint = [
                data_dict[(keypoint_idx, 0)][frame_idx],
                data_dict[(keypoint_idx, 1)][frame_idx],
                data_dict[(keypoint_idx, 2)][frame_idx]
            ]
            smoothed_pose.append(smoothed_keypoint)
        smoothed_pose_data.append([smoothed_pose])

    return smoothed_pose_data