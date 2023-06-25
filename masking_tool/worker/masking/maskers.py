from masking.MPMasker import MPMasker
from masking.NoneMasker import NoneMasker
from models import MaskingStrategy

maskers = {
    MaskingStrategy.MEDIAPIPE: MPMasker,
    MaskingStrategy.NONE: NoneMasker
}