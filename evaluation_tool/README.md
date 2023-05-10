# How to make it work

1. Install requirements
2. Adapt relative paths in config file to MaskedPiper and OpenPose
3. In evaluation_tool.py go to run_approach() (line 118) and make sure to adapt line 129 & 130 if you're not on Windows. Line 131 represents an option that should work platform independently but didn't work on my machine
4. In evaluation_tool.py go to run_approach() (line 118) and make sure to adapt absolute paths (relatives didn't work for whatever reason) and commands executed by Popen for OpenPose so that it works on your machine/platform (Line 137, 138 & 141)
5. If you want you can adapt the video scaling in update_video_label() and open_video_window() (Line 68 & 97)
6. That should make it work!
