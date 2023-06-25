import os

import cv2

from config import RESULT_BASE_PATH


class BaseMasker():
    def __init__(self):
        self.video_path = None
        self.current_frame = None
        self.current_frame_bg = None
        pass

    def mask_face(self):
        pass

    def mask_body(self):
        pass

    def mask_fingers(self):
        pass

    def setup_masking_utilities(self):
        pass

    def pre_process_cur_frame(self):
        pass

    def draw_mask(self, face_mask, body_mask, fingers_mask):
        pass

    def mask(self, video_path: str, bg_video_path: str, face: bool, body: bool, fingers: bool):
        print(f"Masking Video {video_path}. Params set to: face: {face}, body: {body}, fingers: {fingers}")

        capture = cv2.VideoCapture(video_path)
        capture_bg = cv2.VideoCapture(bg_video_path)

        frameWidth = capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frameHeight = capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        samplerate = capture.get(cv2.CAP_PROP_FPS)
        

        if int(capture.get(cv2.CAP_PROP_FRAME_COUNT)) != int(capture_bg.get(cv2.CAP_PROP_FRAME_COUNT)):
            raise Exception("Background Video not same length as Video to mask")

        out_path = video_path.replace('original', 'results')
        print('OUT', out_path)

        """
        vp09 seems to be a reasonable compromise that doesn't require a custom build, works in most modern browsers
        and is comparably efficient
        
        H264 and avc1 aren't supported without a custom build of ffmpeg and python-opencv; See: https://www.swiftlane.com/blog/generating-mp4s-using-opencv-python-with-the-avc1-codec/
        mp4v is not supported by browsers
        """
        fourcc = cv2.VideoWriter_fourcc(*'vp09')
        out = cv2.VideoWriter(out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

        self.setup_masking_utilities()

        first = True
        while capture.isOpened():
            ret, frame = capture.read()
            _, frame_bg = capture_bg.read()

            if ret:
                self.frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                self.frame_bg = frame_bg
                self.frame_timestamp_ms = int(capture.get(cv2.CAP_PROP_POS_MSEC))

                if not first and self.frame_timestamp_ms == 0: # Fallback for videos with bad codec
                    print("Can't properly process some frames - probably due to bad codec. Skipping Frame")
                    continue

                self.pre_process_cur_frame()

                face_res = self.mask_face() if face else None
                body_res = self.mask_body() if body else None
                fingers_res = self.mask_fingers() if fingers else None

                out_frame = self.draw_mask(face_res, body_res, fingers_res)

                out.write(out_frame)
                first = False
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            else:
                break

        out.release()
        capture.release()
        capture_bg.release()
        cv2.destroyAllWindows()
        return out_path