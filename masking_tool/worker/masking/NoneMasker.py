import shutil

from config import RESULT_BASE_PATH
from masking.BaseMasker import BaseMasker


class NoneMasker(BaseMasker):
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
        print(f"Not Masking Video {video_path}. Params set to: face: {face}, body: {body}, fingers: {fingers}")
        self.init_out_dir(video_path)
        shutil.copyfile(bg_video_path, self.output_path)
        return bg_video_path