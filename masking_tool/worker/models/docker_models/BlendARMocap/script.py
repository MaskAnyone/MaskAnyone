import bpy
import os
import time
import sys
import configparser
import getopt

def render_blender_file(video_path, file_path, smoothing_coefficient, export, render):

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
        bpy.ops.wm.save_as_mainfile(filepath="/Docker/output.blend")
    if render:
        bpy.data.scenes["Scene"].render.image_settings.file_format = "FFMPEG"
        bpy.data.scenes["Scene"].render.filepath = "/Docker/"
        bpy.ops.render.render(animation=True, use_viewport=True)


def main():
    cfg = configparser.ConfigParser()
    cfg.read("/Docker/config.ini")

    video_path = cfg["INPUT"]['VideoPath']
    file_path = cfg["INPUT"]['FilePath']
    smoothing_coefficient = cfg["PARAMETERS"].getint('SmoothingCoefficient')
    export = cfg["OUTPUT"].getboolean('Export')
    render = cfg["OUTPUT"].getboolean('Render')

    render_blender_file(video_path, file_path, smoothing_coefficient, export, render)

main()