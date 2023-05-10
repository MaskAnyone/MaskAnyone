import os
from subprocess import Popen, PIPE
import cv2
import shutil
import config
import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageTk


class VideoPlayerApp:
    def __init__(self):
        self.selected_video = None
        self.selected_approaches = []

        self.root = tk.Tk()
        self.root.title("Video Player")

        self.video_frame = tk.Frame(self.root)
        self.video_frame.pack(padx=10, pady=10)

        self.add_video_button = tk.Button(
            self.video_frame, text="Add Video", command=self.open_video_dialog
        )
        self.add_video_button.pack(pady=10)

        self.video_label = tk.Label(self.video_frame, text="")
        self.video_label.pack(pady=5)

        self.approaches_frame = tk.Frame(self.root)
        self.approaches_frame.pack(padx=10, pady=10)

        self.approach_checkboxes = []
        for approach in config.approaches:
            approach_var = tk.IntVar()
            approach_checkbox = tk.Checkbutton(
                self.approaches_frame,
                text=approach['name'],
                variable=approach_var,
                onvalue=1,
                offvalue=0,
            )
            approach_checkbox.pack(pady=5)

            self.approach_checkboxes.append((approach_var, approach_checkbox))

        self.start_button = tk.Button(
            self.root, text="Start", command=self.open_video_windows
        )
        self.start_button.pack(pady=10)

        self.video_windows = []

    def open_video_dialog(self):
        self.selected_video = filedialog.askopenfilename(
            initialdir="/", title="Select Video", filetypes=(("Video files", "*.mp4 *.avi"), ("All files", "*.*"))
        )
        self.video_label.config(text=self.selected_video)

    def open_video_window(self, path):
        cap = cv2.VideoCapture(path)
        ret, frame = cap.read()
        if ret:
            window = tk.Label(self.video_frame)
            window.pack(side=tk.LEFT)

            # Resize the frame to fit the window
            width, height = 320, 240  # Adjust the width and height as needed
            resized_frame = cv2.resize(frame, (width, height))

            # Convert the frame to RGB format
            rgb_frame = cv2.cvtColor(resized_frame, cv2.COLOR_BGR2RGB)

            # Create an ImageTk object from the RGB frame
            image = Image.fromarray(rgb_frame)
            video_image = ImageTk.PhotoImage(image)

            # Create a label to display the video
            video_label = tk.Label(window, image=video_image)
            video_label.pack()

            # Update the video label periodically
            self.update_video_label(window, cap, video_label)

            # Store the video window and its associated components
            self.video_windows.append({
                "window": window,
                "cap": cap,
                "video_label": video_label,
                "video_image": video_image
            })

    def update_video_label(self, window, cap, video_label):
        ret, frame = cap.read()
        if ret:
            # Resize the frame to fit the window
            width, height = 500, 250  # Adjust the width and height as needed
            resized_frame = cv2.resize(frame, (width, height))

            # Convert the frame to RGB format
            rgb_frame = cv2.cvtColor(resized_frame, cv2.COLOR_BGR2RGB)

            # Create an ImageTk object from the RGB frame
            image = Image.fromarray(rgb_frame)
            video_image = ImageTk.PhotoImage(image)

            # Update the video label with the new image
            video_label.configure(image=video_image)
            video_label.image = video_image

            # Schedule the next update
            window.after(20, lambda: self.update_video_label(window, cap, video_label))
        else:
            # Release the video capture and destroy the window
            cap.release()
            window.destroy()

    def run_approach(self, approach_name, approach_path):
        if approach_name == 'MaskedPiper':
            input_folder = '/Input_Videos/'
            output_folder = '/Output_MaskedVideos/'


            # Setup everything needed to run the MultiModalOpenScience repo
            # copy file to input folder, run .bat or .py file and return the output path
            shutil.copyfile(self.selected_video, approach_path + input_folder + 'video.mp4')

            # executing the .py file doesn't work for me so quick fix was to run the .bat (Windows only though :( )
            p = Popen("Masked-PiperSTART.bat", cwd=approach_path, stdin=PIPE, shell=True)
            p.communicate(input=b'\n')
            #exec(open('./Masked-PiperPY.py').read())

            os.remove(approach_path + input_folder + 'video.mp4')
            return approach_path + output_folder + 'video.mp4'

        if approach_name == 'OpenPose':
            input_path = "C:\\Users\\Nickl\\DataspellProjects\\openpose\\examples\\media\\video.mp4"
            output_path = "C:\\Users\\Nickl\\DataspellProjects\\openpose\\examples\\media\\output_1.avi"
            shutil.copyfile(self.selected_video, input_path)

            p = Popen('C:\\Users\\Nickl\\DataspellProjects\\openpose\\bin\\OpenPoseDemo.exe' + ' --video ' + input_path + ' --write_video ' + output_path, cwd=approach_path, stdin=PIPE, shell=True)
            p.communicate()

            os.remove(input_path)
            return output_path

    def open_video_windows(self):
        if self.selected_video:
            self.open_video_window(self.selected_video)
            for i, approach in enumerate(config.approaches):
                if self.approach_checkboxes[i][0].get() == 1:
                    output_path = self.run_approach(approach['name'], approach['path'])
                    self.open_video_window(output_path)

        for video_window in self.video_windows:
            video_window["window"].pack()

if __name__ == "__main__":
    app = VideoPlayerApp()
    app.root.mainloop()


#%%
