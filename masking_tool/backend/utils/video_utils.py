import cv2


def extract_codec_from_capture(capture) -> str:
    h = int(capture.get(cv2.CAP_PROP_FOURCC))

    codec = (
            chr(h & 0xFF)
            + chr((h >> 8) & 0xFF)
            + chr((h >> 16) & 0xFF)
            + chr((h >> 24) & 0xFF)
    )

    return codec