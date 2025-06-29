from queue import Queue
from threading import Thread
import cv2

class AsyncVideoWriter:
    def __init__(self, output_path, frame_size, fps, queue_size=32):
        self.queue = Queue(maxsize=queue_size)
        self.writer = cv2.VideoWriter(
            output_path,
            cv2.VideoWriter_fourcc(*'mp4v'),
            fps,
            frame_size
        )
        self.thread = Thread(target=self._write_frames)
        self.thread.daemon = True
        self.running = True
        self.thread.start()

    def _write_frames(self):
        while self.running:
            frame = self.queue.get()
            if frame is None:
                break  # Sentinel to end thread
            self.writer.write(frame)
            self.queue.task_done()

    def write(self, frame):
        self.queue.put(frame)

    def close(self):
        self.queue.put(None)  # Send sentinel
        self.thread.join()
        self.writer.release()
