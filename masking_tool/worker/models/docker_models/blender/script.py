import bpy
import os
import time
import sys
import argparse


def render_blender_file(
    video_path,
    file_name,
    smoothing_coefficient,
    export,
    render,
    output_video_path,
    output_file_path,
):
    file_path = os.path.join("/blender/char_files", file_name + ".blend")
    print(file_path)
    print(video_path)
    print(output_video_path)
    print(output_file_path)
    print(export)
    print(render)
    print(os.path.exists(video_path))
    bpy.ops.preferences.addon_enable(module="rigify")
    bpy.ops.preferences.addon_enable(module="BlendArMocap")
    bpy.ops.wm.open_mainfile(filepath=file_path)

    """bpy.ops.object.armature_human_metarig_add()
    bpy.ops.pose.rigify_generate()"""

    bpy.data.scenes["Scene"].cgtinker_mediapipe.mov_data_path = video_path
    bpy.data.scenes["Scene"].cgtinker_mediapipe.key_frame_step = smoothing_coefficient
    bpy.data.scenes["Scene"].cgtinker_mediapipe.enum_detection_type = "HOLISTIC"
    # bpy.data.scenes["Scene"].frame_end = 10

    bpy.ops.wm.cgt_feature_detection_operator()

    print("a")
    bpy.data.scenes[
        "Scene"
    ].cgtinker_transfer.selected_driver_collection = bpy.data.collections["cgt_DRIVERS"]
    print("b")
    bpy.data.scenes["Scene"].cgtinker_transfer.selected_rig = bpy.data.objects["rig"]
    print("c")

    bpy.ops.button.cgt_object_apply_properties()
    print("d")
    if export:
        print("e1")
        bpy.ops.wm.save_as_mainfile(filepath=output_file_path)
        print("e2")
    if render:
        bpy.data.scenes["Scene"].render.image_settings.file_format = "FFMPEG"
        bpy.data.scenes["Scene"].render.filepath = output_video_path
        bpy.ops.render.render(animation=True, use_viewport=True)


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

    args = argParser.parse_args()

    render_blender_file(
        args.invid,
        args.charfilename,
        args.smoothing,
        args.export,
        args.render,
        args.outvid,
        args.outfile,
    )


main()
