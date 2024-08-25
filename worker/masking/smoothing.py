import numpy as np
from scipy.signal import butter, filtfilt


def butter_it(x, sampling_rate, order, lowpass_cutoff):
    nyquist = sampling_rate / 2
    cutoff = lowpass_cutoff / nyquist  # Normalized frequency
    b, a = butter(order, cutoff, btype='low')
    filtered_x = filtfilt(b, a, x)
    return np.asarray(filtered_x, dtype=np.float64)


def interpolate_small_gaps(data, max_gap, max_distance):
    """Interpolate small gaps (gaps of max_gap or less) in the data,
    but skip interpolation if the gap between known values is too large."""
    data = np.array(data, dtype=float)
    nans = np.isnan(data)
    indices = np.arange(len(data))

    # Identify and interpolate small gaps
    for start, stop in contiguous_regions(nans):
        if stop - start <= max_gap:
            # Check the distance between the values before and after the gap
            prev_value = data[start - 1] if start - 1 >= 0 else np.nan
            next_value = data[stop] if stop < len(data) else np.nan

            if np.abs(next_value - prev_value) <= max_distance:
                data[start:stop] = np.interp(indices[start:stop], indices[~nans], data[~nans])

    return data


def fill_larger_gaps(data):
    """Fill larger gaps in the data with the nearest non-NaN values."""
    data = np.array(data, dtype=float)
    nans = np.isnan(data)
    data[nans] = np.interp(np.where(nans)[0], np.where(~nans)[0], data[~nans])
    return data


def contiguous_regions(condition):
    """Find the indices of contiguous True regions in a boolean array."""
    d = np.diff(condition)
    idx, = d.nonzero()
    idx += 1
    if condition[0]:
        idx = np.r_[0, idx]
    if condition[-1]:
        idx = np.r_[idx, condition.size]
    idx.shape = (-1, 2)
    return idx


def compute_final_data(data_interpolated, smoothed_data, frame_cut_detection_threshold=200):
    """Process data to avoid smoothing artifacts at frame cuts."""
    data_final = []
    num_points = len(data_interpolated)

    i = 0
    while i < num_points:
        if np.isnan(data_interpolated[i]):
            data_final.append(None)
        else:
            data_final.append(smoothed_data[i])

        i += 1

    return data_final


def smooth_pose(pose_data, sampling_rate, order=3, lowpass_cutoff=12):
    # The butterworth filter will break if we have too few data points
    if pose_data is None or len(pose_data) < 30:
        return pose_data

    # Check if pose_data is None everywhere (all frames are None)
    if all(pose is None for pose in pose_data):
        return pose_data

    pose_keypoint_count = None
    for pose in pose_data:
        if pose is not None:
            pose_keypoint_count = len(pose)
            break

    # sampling_rate should match video framerate
    raw_data_dict = {}

    # Populate data_dict with keypoint data
    for frame_idx, frame_pose in enumerate(pose_data):
        if frame_pose is None:
            # Fill dict with None values to be handled later
            for keypoint_idx in range(pose_keypoint_count):
                raw_data_dict.setdefault((keypoint_idx, 0), []).append(None)
                raw_data_dict.setdefault((keypoint_idx, 1), []).append(None)
            continue

        for keypoint_idx, keypoint in enumerate(frame_pose):
            if keypoint is None or keypoint[0] < 1 and keypoint[1] < 1:
                # Treat (0, 0) as missing data
                raw_data_dict.setdefault((keypoint_idx, 0), []).append(None)
                raw_data_dict.setdefault((keypoint_idx, 1), []).append(None)
            else:
                raw_data_dict.setdefault((keypoint_idx, 0), []).append(keypoint[0])
                raw_data_dict.setdefault((keypoint_idx, 1), []).append(keypoint[1])

    # Butterworth filter order (reasonable values: 1-5)

    # Hz 10 (heavy) to 15 (most movements don't happen in less than 100ms)
    # Lowpass cutoff must not exceed frame_rate/2
    lowpass_cutoff = min((sampling_rate // 2) - 1, lowpass_cutoff)

    smoothed_data_dict = {}
    interpolated_data_dict = {}

    max_interpolation_distance = 25 * (30 / sampling_rate)
    max_interpolation_gap = sampling_rate // 3

    for key in raw_data_dict.keys():
        data = raw_data_dict[key]

        # If there are only none values for a given keypoint we can't do anything
        if all(point is None for point in data):
            smoothed_data_dict[key] = data
            interpolated_data_dict[key] = [np.nan for _ in data]
            continue

        # Convert None to NaN for easier processing
        data = [np.nan if v is None else v for v in data]

        # Step 1: Interpolate small gaps
        data_interpolated = interpolate_small_gaps(data, max_gap=max_interpolation_gap, max_distance=max_interpolation_distance)

        # Step 2: Fill larger gaps with nearest values
        data_filled = fill_larger_gaps(data_interpolated)

        # Step 3: Apply smoothing
        smoothed_data = butter_it(data_filled, sampling_rate, order, lowpass_cutoff)

        # Step 4: Restore larger gaps (set them back to NaN)
        data_final = compute_final_data(data_interpolated, smoothed_data)

        smoothed_data_dict[key] = data_final
        interpolated_data_dict[key] = data_interpolated

    # Reconstruct the pose data from smoothed data_dict
    smoothed_pose_data = []

    # How many frames to flag before and after the frame cut
    frame_cut_buffer_length = 7

    # Pose keypoint threshold to detect frame cuts
    # Should optimally be relative to frame size, pose size and frame rate
    # i.e. what is the max distance a fast movement might be between two frames?
    threshold = 60 * (30 / sampling_rate)

    flagged_frames = set()

    # Step 1: Calculate distances and flag frames
    for frame_idx in range(1, len(pose_data)):
        if pose_data[frame_idx] is None or pose_data[frame_idx - 1] is None:
            continue

        for keypoint_idx in range(len(pose_data[frame_idx])):
            interpolated_x_current = interpolated_data_dict[(keypoint_idx, 0)][frame_idx]
            interpolated_y_current = interpolated_data_dict[(keypoint_idx, 1)][frame_idx]
            interpolated_x_prev = interpolated_data_dict[(keypoint_idx, 0)][frame_idx - 1]
            interpolated_y_prev = interpolated_data_dict[(keypoint_idx, 1)][frame_idx - 1]

            if (np.isnan(interpolated_x_current) or
                    np.isnan(interpolated_y_current) or
                    np.isnan(interpolated_x_prev) or
                    np.isnan(interpolated_y_prev)):
                continue

            distance = ((interpolated_x_current - interpolated_x_prev) ** 2 +
                        (interpolated_y_current - interpolated_y_prev) ** 2) ** 0.5

            if distance > threshold:
                # Flag this frame and a few frames before and after
                for i in range(max(0, frame_idx - frame_cut_buffer_length), min(len(pose_data), frame_idx + frame_cut_buffer_length + 1)):
                    flagged_frames.add(i)

    print('FlaggedFrames', flagged_frames)

    # Step 2: Construct smoothed_pose_data considering flagged frames
    for frame_idx in range(len(pose_data)):
        if pose_data[frame_idx] is None:
            smoothed_pose_data.append(None)
            continue

        smoothed_pose = []

        for keypoint_idx in range(len(pose_data[frame_idx])):
            if frame_idx in flagged_frames:
                smoothed_x = interpolated_data_dict[(keypoint_idx, 0)][frame_idx]
                smoothed_y = interpolated_data_dict[(keypoint_idx, 1)][frame_idx]

                smoothed_x = None if np.isnan(smoothed_x) else smoothed_x
                smoothed_y = None if np.isnan(smoothed_y) else smoothed_y
            else:
                smoothed_x = smoothed_data_dict[(keypoint_idx, 0)][frame_idx]
                smoothed_y = smoothed_data_dict[(keypoint_idx, 1)][frame_idx]

            smoothed_keypoint = [smoothed_x, smoothed_y]

            if any(prop is None for prop in smoothed_keypoint):
                smoothed_pose.append(None)
            else:
                smoothed_pose.append(smoothed_keypoint)

        if all(keypoint is None for keypoint in smoothed_pose):
            smoothed_pose_data.append(None)
        else:
            smoothed_pose_data.append(smoothed_pose)

    return smoothed_pose_data