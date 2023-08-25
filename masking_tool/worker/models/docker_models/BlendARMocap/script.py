import bpy
import os
import time
import sys
import argparse

def render_blender_file(video_path, file_path, smoothing_coefficient, export, render, output_video_path, output_file_path):

    bpy.ops.preferences.addon_enable(module="rigify")
    bpy.ops.preferences.addon_enable(module='BlendArMocap')
    bpy.ops.wm.open_mainfile(filepath=file_path)

    """bpy.ops.object.armature_human_metarig_add()
    bpy.ops.pose.rigify_generate()"""

    bpy.data.scenes["Scene"].cgtinker_mediapipe.mov_data_path = video_path
    bpy.data.scenes["Scene"].cgtinker_mediapipe.key_frame_step = smoothing_coefficient
    bpy.data.scenes["Scene"].cgtinker_mediapipe.enum_detection_type = "HOLISTIC"
    #bpy.data.scenes["Scene"].frame_end = 10

    bpy.ops.wm.cgt_feature_detection_operator()

    bpy.data.scenes["Scene"].cgtinker_transfer.selected_driver_collection = bpy.data.collections["cgt_DRIVERS"]
    bpy.data.scenes["Scene"].cgtinker_transfer.selected_rig = bpy.data.objects["rig"]

    bpy.ops.button.cgt_object_apply_properties()

    if export:
        bpy.ops.wm.save_as_mainfile(filepath=output_file_path)
    if render:
        bpy.data.scenes["Scene"].render.image_settings.file_format = "FFMPEG"
        bpy.data.scenes["Scene"].render.filepath = output_video_path
        bpy.ops.render.render(animation=True, use_viewport=True)


def main():
    argParser = argparse.ArgumentParser()
    argParser.add_argument('-i', '--invid', type=str, help="Input video path")
    argParser.add_argument('-c', '--charfile', type=str, help="Blender rig file path")
    argParser.add_argument('-o', '--outvid', type=str, help="Output video path")
    argParser.add_argument('-f', '--outfile', type=str, help="Output blender file path")
    argParser.add_argument('-r', '--render', type=int, help="Should the video be rendered (1-yes, 0-no)")
    argParser.add_argument('-e', '--export', type=int, help="Should the blender file be exported (1-yes, 0-no)")
    argParser.add_argument('-s', '--smoothing', type=int, help="Smoothing coefficient")

    args = argParser.parse_args()

    render_blender_file(args.invid, args.charfile, args.smoothing, args.export, args.render, args.outvid, args.outfile)

main()