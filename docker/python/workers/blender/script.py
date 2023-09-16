import tempfile
import bpy
import os
import time
import sys
import argparse
import cv2
import math
import requests


class RenderBlenderFile:
    def __init__(
        self,
        video_path,
        rig_file_name,
        smoothing_coefficient,
        export,
        render,
        output_video_file,
        output_blender_file,
        backend_url,
    ):
        self.video_path = video_path
        self.rig_path = os.path.join("/blender/char_files", rig_file_name + ".blend")
        self.smoothing_coefficient = smoothing_coefficient
        self.export = export
        self.render = render

        self.output_video_file = output_video_file
        self.output_video_path = output_video_file[: output_video_file.rfind("/") + 1]

        self.output_blender_file = output_blender_file
        self.backend_url = backend_url

        self.mode = 100 + render * (-50)
        self.last_progress = 0

        cap = cv2.VideoCapture(video_path)
        self.fps = cap.get(cv2.CAP_PROP_FPS)
        self.total_frames = cap.get(cv2.CAP_PROP_FRAME_COUNT)

    def load_prereqs(self):
        bpy.ops.preferences.addon_enable(module="rigify")
        bpy.ops.preferences.addon_enable(module="BlendArMocap")
        bpy.ops.wm.open_mainfile(filepath=self.rig_path)

        self.set_scene()

    def set_scene(self):
        bpy.data.scenes["Scene"].cgtinker_mediapipe.mov_data_path = self.video_path
        bpy.data.scenes[
            "Scene"
        ].cgtinker_mediapipe.key_frame_step = self.smoothing_coefficient
        bpy.data.scenes["Scene"].cgtinker_mediapipe.enum_detection_type = "HOLISTIC"

    def mediapipe_detect(self):
        with open("tmp.txt", "w") as f:
            f.write(f"{self.backend_url},{self.mode}")

        bpy.ops.wm.cgt_feature_detection_operator()

        if os.path.isfile("tmp.txt"):
            os.remove("tmp.txt")
        else:
            print("Error: tmp.txt file not found")

    def coordinate_transfer(self):
        bpy.data.scenes[
            "Scene"
        ].cgtinker_transfer.selected_driver_collection = bpy.data.collections[
            "cgt_DRIVERS"
        ]
        bpy.data.scenes["Scene"].cgtinker_transfer.selected_rig = bpy.data.objects[
            "rig"
        ]

        bpy.ops.button.cgt_object_apply_properties()

    def export_blend_file(self):
        bpy.ops.wm.save_as_mainfile(filepath=self.output_blender_file)

    def render_frame(self, frame_id, scene):
        scene.frame_set(frame_id)

        if frame_id < 10:
            frame_name = "0" + str(frame_id)
        else:
            frame_name = str(frame_id)

        scene.render.filepath = self.output_video_path + frame_name
        bpy.ops.render.render(write_still=True, use_viewport=True)

        self.update_render_progress(frame_id)

    def update_render_progress(self, frame_id):
        cur_progress = int((frame_id / self.total_frames) * 50) + 50
        if (cur_progress - self.last_progress) >= 5:
            print("XXXXXXXXXXXXX", cur_progress)
            requests.post(self.backend_url, json={"progress": cur_progress})
            self.last_progress = cur_progress

    def merge_images_to_video(self):
        images = [
            img for img in os.listdir(self.output_video_path) if img.endswith(".png")
        ]
        frame = cv2.imread(os.path.join(self.output_video_path, images[0]))
        height, width, layers = frame.shape

        video = cv2.VideoWriter(
            self.output_video_file,
            cv2.VideoWriter_fourcc(*"mp4v"),
            self.fps,
            (width, height),
        )

        for image in images:
            path = os.path.join(self.output_video_path, image)
            video.write(cv2.imread(path))
            if os.path.isfile(path):
                os.remove(path)
            else:
                print(f"Error: {image} file not found")

        print("XXXXXXXXXXXXX", 100)
        requests.post(self.backend_url, json={"progress": 100})

        cv2.destroyAllWindows()
        video.release()

    def run(self):
        self.load_prereqs()
        self.mediapipe_detect()
        self.coordinate_transfer()
        if self.export:
            self.export_blend_file()
        if self.render:
            for frame in range(0, int(self.total_frames)):
                scene = bpy.context.scene
                scene.render.image_settings.file_format = "PNG"
                self.render_frame(frame, scene)

            self.merge_images_to_video()


def main():
    argParser = argparse.ArgumentParser()
    argParser.add_argument(
        "-i", "--in-path", type=str, help="Input video path", dest="invid"
    )
    argParser.add_argument(
        "-c", "--character", type=str, help="Blender rig file name", dest="charfilename"
    )
    argParser.add_argument(
        "-o", "--out-path", type=str, help="Output video path", dest="outvid"
    )
    argParser.add_argument(
        "-f",
        "--out-path-extra",
        type=str,
        help="Output blender file path",
        dest="outfile",
    )
    argParser.add_argument(
        "-r",
        "--render",
        type=int,
        help="Should the video be rendered (0 no, 1 yes)",
        dest="render",
    )
    argParser.add_argument(
        "-e",
        "--export",
        type=int,
        help="Should the blender file be exported(0 no, 1 yes)",
        dest="export",
    )
    argParser.add_argument(
        "-s", "--smoothing", type=int, help="Smoothing coefficient", dest="smoothing"
    )

    argParser.add_argument(
        "-b", "--backend-update-url", type=str, help="Backend URL", dest="backendurl"
    )

    args = argParser.parse_args()

    RenderBlenderFile(
        args.invid,
        args.charfilename,
        args.smoothing,
        args.export,
        args.render,
        args.outvid,
        args.outfile,
        args.backendurl,
    ).run()


main()
