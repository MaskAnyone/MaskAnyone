import numpy as np
from scipy.signal import butter, filtfilt


def butter_it(x, sampling_rate, order, lowpass_cutoff):
    nyquist = sampling_rate / 2
    cutoff = lowpass_cutoff / nyquist  # Normalized frequency
    b, a = butter(order, cutoff, btype='low')
    filtered_x = filtfilt(b, a, x)
    return np.asarray(filtered_x, dtype=np.float64)


def interpolate_small_gaps(data, max_gap=3):
    """Interpolate small gaps (gaps of max_gap or less) in the data."""
    data = np.array(data, dtype=float)
    nans = np.isnan(data)
    indices = np.arange(len(data))

    # Identify and interpolate small gaps
    for start, stop in contiguous_regions(nans):
        if stop - start <= max_gap:
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
        """
        if i < (num_points - 1):
            should_override_points = False

            # Try to figure out if we're dealing with a frame cut
            if not np.isnan(data_interpolated[i]) and not np.isnan(data_interpolated[i + 1]):
                distance = np.linalg.norm(np.array(data_interpolated[i]) - np.array(data_interpolated[i + 1]))
                if distance > frame_cut_detection_threshold:
                    should_override_points = True
            else:
                should_override_points = True

            # If there is likely a frame cut, fall back to the raw data just to be sure
            if should_override_points:
                data_final.append(data_interpolated[i] if not np.isnan(data_interpolated[i]) else None)
                data_final.append(data_interpolated[i + 1] if not np.isnan(data_interpolated[i + 1]) else None)

                if i > 0:
                    data_final[i - 1] = data_interpolated[i - 1] if not np.isnan(data_interpolated[i - 1]) else None

                if i < (num_points - 2):
                    data_final.append(data_interpolated[i + 2] if not np.isnan(data_interpolated[i + 2]) else None)
                    i += 1

                i += 1
                continue
        """

        if np.isnan(data_interpolated[i]):
            data_final.append(None)
        else:
            data_final.append(smoothed_data[i])

        i += 1

    return data_final


def smooth_pose(pose_data, sampling_rate):
    # The butterworth filter will break if we have too few data points
    if pose_data is None or len(pose_data) < 50:
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
    data_dict = {}

    # Populate data_dict with keypoint data
    for frame_idx, frame_pose in enumerate(pose_data):
        if frame_pose is None:
            # Fill dict with None values to be handled later
            for keypoint_idx in range(pose_keypoint_count):
                data_dict.setdefault((keypoint_idx, 0), []).append(None)
                data_dict.setdefault((keypoint_idx, 1), []).append(None)
                data_dict.setdefault((keypoint_idx, 2), []).append(None)
            continue

        for keypoint_idx, keypoint in enumerate(frame_pose):
            if keypoint is None or keypoint[0] < 1 and keypoint[1] < 1:
                # Treat (0, 0) as missing data
                data_dict.setdefault((keypoint_idx, 0), []).append(None)
                data_dict.setdefault((keypoint_idx, 1), []).append(None)
                data_dict.setdefault((keypoint_idx, 2), []).append(None)
            else:
                data_dict.setdefault((keypoint_idx, 0), []).append(keypoint[0])
                data_dict.setdefault((keypoint_idx, 1), []).append(keypoint[1])
                data_dict.setdefault((keypoint_idx, 2), []).append(keypoint[2])

    order = 1  # Butterworth filter order (reasonable values: 1-5)

    # Hz 10 (heavy) to 15 (most movements don't happen in less than 100ms)
    # Lowpass cutoff must not exceed frame_rate/2
    lowpass_cutoff = min((sampling_rate // 2) - 1, 20)

    for key in data_dict.keys():
        data = data_dict[key]

        # If there are only none values for a given keypoint we can't do anything
        if all(point is None for point in data):
            continue

        # Convert None to NaN for easier processing
        data = [np.nan if v is None else v for v in data]

        # Step 1: Interpolate small gaps (1 frames or less)
        data_interpolated = interpolate_small_gaps(data, max_gap=1)

        # Step 2: Fill larger gaps with nearest values
        data_filled = fill_larger_gaps(data_interpolated)

        # Step 3: Apply smoothing
        smoothed_data = butter_it(data_filled, sampling_rate, order, lowpass_cutoff)

        # Step 4: Restore larger gaps (set them back to NaN)
        data_final = compute_final_data(data_interpolated, smoothed_data)

        # Replace the original data in the dictionary with the final smoothed data
        data_dict[key] = data_final

    # Reconstruct the pose data from smoothed data_dict
    smoothed_pose_data = []

    for frame_idx in range(len(pose_data)):
        smoothed_pose = []

        if pose_data[frame_idx] is None:
            smoothed_pose_data.append(None)
            continue

        for keypoint_idx in range(len(pose_data[frame_idx])):
            smoothed_keypoint = [
                data_dict[(keypoint_idx, 0)][frame_idx],
                data_dict[(keypoint_idx, 1)][frame_idx],
                data_dict[(keypoint_idx, 2)][frame_idx]
            ]

            if any(prop is None for prop in smoothed_keypoint):
                smoothed_pose.append(None)
            else:
                smoothed_pose.append(smoothed_keypoint)

        if all(keypoint is None for keypoint in smoothed_pose):
            smoothed_pose_data.append(None)
        else:
            smoothed_pose_data.append(smoothed_pose)

    return smoothed_pose_data