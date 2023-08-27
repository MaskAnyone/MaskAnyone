import subprocess


class STTNVideoInpainter:
    def run(self, original_video_path: str, inpaint_mask_dir: str):
        args = [
            "python3",
            "/STTN/test.py",
            "--video",
            original_video_path,
            "--mask",
            inpaint_mask_dir,
            "--ckpt",
            "/STTN/checkpoints/sttn.pth"
        ]

        res = subprocess.run(
            args,
            capture_output=True,
            cwd="/STTN",
        )

        if res.stderr:
            print(res)

        return inpaint_mask_dir + '_result.mp4'
