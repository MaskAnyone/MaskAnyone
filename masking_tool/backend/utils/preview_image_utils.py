import cv2


def aspect_preserving_resize_and_crop(frame, width: int, height: int):
    """
    Resize the frame preserving the aspect ratio and crop the excess part to
    get to the desired size.

    Args:
        frame (np.array): The frame to resize and crop.
        width (int): The desired width.
        height (int): The desired height.

    Returns:
        np.array: The resized and cropped frame.
    """
    frame_height, frame_width, frame_channels = frame.shape
    frame_aspect_ratio = frame_width / frame_height
    desired_aspect_ratio = width / height

    if frame_aspect_ratio < desired_aspect_ratio:
        new_width = width
        new_height = int(new_width / frame_aspect_ratio)
    else:
        new_height = height
        new_width = int(new_height * frame_aspect_ratio)

    resized_frame = cv2.resize(frame, (new_width, new_height))

    height_offset = (new_height - height) // 2
    width_offset = (new_width - width) // 2
    cropped_frame = resized_frame[height_offset:height_offset + height, width_offset:width_offset + width]

    return cropped_frame


