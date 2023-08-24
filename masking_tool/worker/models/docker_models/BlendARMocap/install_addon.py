import bpy


def install_addon():
    bpy.ops.preferences.addon_install(filepath='./BlendArMocap.zip')
    bpy.ops.preferences.addon_enable(module='BlendArMocap')
    bpy.data.scenes["Scene"].cgtinker_mediapipe.local_user = True
    bpy.ops.button.cgt_install_dependencies()


if __name__ == "__main__":
    install_addon()