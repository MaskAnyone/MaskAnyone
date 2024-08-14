import numpy
from scipy.signal import butter, filtfilt


def butter_it(x, sampling_rate, order, lowpass_cutoff):
    nyquist = sampling_rate / 2
    cutoff = lowpass_cutoff / nyquist  # Normalized frequency
    b, a = butter(order, cutoff, btype='low')
    filtered_x = filtfilt(b, a, x)
    #return filtered_x
    return numpy.asarray(filtered_x, dtype=numpy.float64)


def smooth_pose(pose):
    # Initialize lists to store the attribute data for each landmark
    landmark_series = {'x': [], 'y': [], 'z': []}

    for idx, landmark in enumerate(pose):
        landmark_series['x'].append(landmark.x)
        landmark_series['y'].append(landmark.y)
        landmark_series['z'].append(landmark.z)

    # Filter parameters
    sampling_rate = 30  # Should match video framerate?
    order = 3  # (2-4)
    lowpass_cutoff = 10  # Hz 10 (heavy) to 15 (most movements don't happen in less than 100ms)

    for attr in ['x', 'y', 'z']:
        landmark_series[attr] = butter_it(numpy.array(landmark_series[attr]), sampling_rate, order, lowpass_cutoff)

    for idx in range(len(pose)):
        pose[idx].x = landmark_series['x'][idx]
        pose[idx].y = landmark_series['y'][idx]
        pose[idx].z = landmark_series['z'][idx]


def smooth_poses(mp_pose_landmarks):
    for idx in range(len(mp_pose_landmarks)):
        smooth_pose(mp_pose_landmarks[idx])

