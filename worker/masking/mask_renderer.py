import cv2
import numpy as np


BLURRING_LEVELS = {
    1: (15, 15),
    2: (20, 20),
    3: (25, 25),
    4: (35, 35),
    5: (51, 51)
}

PIXELATION_LEVELS = {
    1: 150,
    2: 100,
    3: 70,
    4: 50,
    5: 30
}

CONTOURS_LEVELS = {
    1: {
        "blur_kernel_size": 3,
        "laplacian_kernel_size": 3,
        "laplacian_scale": 1.9,
        "laplacian_delta": 20,
    },
    2: {
        "blur_kernel_size": 5,
        "laplacian_kernel_size": 5,
        "laplacian_scale": 1,
        "laplacian_delta": -20,
    },
    3: {
        "blur_kernel_size": 7,
        "laplacian_kernel_size": 5,
        "laplacian_scale": 1,
        "laplacian_delta": -10,
    },
    4: {
        "blur_kernel_size": 11,
        "laplacian_kernel_size": 5,
        "laplacian_scale": 1,
        "laplacian_delta": 0,
    },
    5: {
        "blur_kernel_size": 17,
        "laplacian_kernel_size": 5,
        "laplacian_scale": 1.2,
        "laplacian_delta": 10,
    },
}

class MaskRenderer:
    _strategy: str
    _options: dict

    def __init__(self, strategy: str, options: dict):
        self._strategy = strategy
        self._options = options

    def apply_to_image(self, rgb_image, boolean_segmentation_mask):
        if self._strategy == 'solid_fill':
            self._apply_solid_fill_to_image(rgb_image, boolean_segmentation_mask)
        elif self._strategy == 'blurring':
            self._apply_blur_to_image(rgb_image, boolean_segmentation_mask)
        elif self._strategy == 'pixelation':
            self._apply_pixelation_to_image(rgb_image, boolean_segmentation_mask)
        elif self._strategy == 'contours':
            self._apply_contours_to_image(rgb_image, boolean_segmentation_mask)
        else:
            raise Exception(f'Unknown video masking strategy, got {self._strategy}')

    def _apply_solid_fill_to_image(self, rgb_image, boolean_segmentation_mask):
        if self._options['averageColor']:
            average_color = np.mean(rgb_image, axis=(0, 1)).astype(int)
            fill_color = average_color
        else:
            fill_color = self._hex_to_rgb(self._options['color'])[::-1]

        rgb_image[boolean_segmentation_mask] = fill_color

    def _apply_blur_to_image(self, rgb_image, boolean_segmentation_mask):
        kernel_size = BLURRING_LEVELS[self._options['level']]
        blurred_image = cv2.GaussianBlur(rgb_image, kernel_size, 0)
        rgb_image[boolean_segmentation_mask] = blurred_image[boolean_segmentation_mask]

    def _apply_pixelation_to_image(self, rgb_image, boolean_segmentation_mask):
        height, width = rgb_image.shape[:2]
        aspect_ratio = width / height

        small_height = PIXELATION_LEVELS[self._options['level']]
        small_width = int(small_height * aspect_ratio)

        small_image = cv2.resize(rgb_image, (small_width, small_height), interpolation=cv2.INTER_LINEAR)
        pixelated_image = cv2.resize(small_image, (width, height), interpolation=cv2.INTER_NEAREST)
        rgb_image[boolean_segmentation_mask] = pixelated_image[boolean_segmentation_mask]

    def _apply_contours_to_image(self, rgb_image, boolean_segmentation_mask):
        level_settings = CONTOURS_LEVELS[self._options['level']]

        blurred_image = cv2.GaussianBlur(
            rgb_image,
            (level_settings["blur_kernel_size"], level_settings["blur_kernel_size"]),
            0,
        )

        gray_image = cv2.cvtColor(blurred_image, cv2.COLOR_RGB2GRAY)
        edge_image = cv2.Laplacian(
            gray_image,
            -1,
            ksize=level_settings["laplacian_kernel_size"],
            scale=level_settings["laplacian_scale"],
            delta=level_settings["laplacian_delta"],
            borderType=cv2.BORDER_DEFAULT,
        )
        final_contours_image = cv2.cvtColor(edge_image, cv2.COLOR_GRAY2RGB)

        rgb_image[boolean_segmentation_mask] = final_contours_image[boolean_segmentation_mask]

    def _hex_to_rgb(self, hex_color):
        hex_color = hex_color.lstrip('#')

        hex_int = int(hex_color, 16)

        r = (hex_int >> 16) & 255
        g = (hex_int >> 8) & 255
        b = hex_int & 255

        return r, g, b