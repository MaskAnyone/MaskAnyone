import { useState } from 'react';
import { Button, Chip, Popover, Tooltip, Typography } from '@mui/material';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';

interface ModelOption {
    value: string;
    label: string;
    hint: string;
}

interface ModelGroup {
    label: string;
    options: ModelOption[];
}

const MODEL_GROUPS: ModelGroup[] = [
    {
        label: 'No overlay',
        options: [
            { value: 'none', label: 'None', hint: 'No pose overlay.' },
        ],
    },
    {
        label: 'Human — RTMPose',
        options: [
            { value: 'rtmpose_s', label: 'S', hint: 'Fastest, least accurate. Good for quick previews.' },
            { value: 'rtmpose_m', label: 'M', hint: 'Balanced speed and accuracy. Recommended default for humans.' },
            { value: 'rtmpose_l', label: 'L', hint: 'Most accurate for humans, slowest of the three.' },
        ],
    },
    {
        label: 'Animal',
        options: [
            { value: 'rtmpose_ap10k', label: 'AP-10K', hint: 'HRNet-W32 trained on AP-10K (54 species). Baseline animal model.' },
            { value: 'rtmpose_ap10k_w48', label: 'AP-10K W48', hint: 'Larger HRNet-W48 backbone on AP-10K. More accurate, slower.' },
            { value: 'rtmpose_ap10k_rtm', label: 'AP-10K RTMPose ★', hint: 'RTMPose backbone on AP-10K. Best confidence for primates in benchmarks. Recommended for animal use.' },
            { value: 'rtmpose_animalpose', label: 'AnimalPose', hint: 'Trained on cat, dog, horse, sheep, cow. Good for domestic animals.' },
            { value: 'rtmpose_ak_mammal', label: 'Animal Kingdom (mammal)', hint: 'Mammal-specific model from Animal Kingdom dataset. Best option for primates.' },
        ],
    },
    {
        label: 'Human — MediaPipe',
        options: [
            { value: 'mp_pose', label: 'Pose', hint: 'Full-body pose. Fast, CPU-friendly, good for single person.' },
            { value: 'mp_face', label: 'Face', hint: 'Face mesh — 468 facial landmarks.' },
            { value: 'mp_hand', label: 'Hands', hint: 'Hand landmarks — 21 keypoints per hand.' },
        ],
    },
    {
        label: 'Human — OpenPose',
        options: [
            { value: 'openpose', label: 'Body', hint: 'Classic BODY_25 keypoints. Good multi-person support.' },
            { value: 'openpose_body25b', label: 'BODY_25B', hint: 'Improved 25-keypoint model with better foot detection.' },
            { value: 'openpose_face', label: '+ Face', hint: 'Body keypoints plus facial detail. Heavier.' },
            { value: 'openpose_body_135', label: 'BODY_135', hint: 'Full body including hands and face. Most detailed, slowest.' },
        ],
    },
];

const ALL_OPTIONS = MODEL_GROUPS.flatMap(g => g.options);

interface ModelPickerProps {
    value: string;
    onChange: (value: string) => void;
}

const ModelPicker = ({ value, onChange }: ModelPickerProps) => {
    const [anchor, setAnchor] = useState<HTMLButtonElement | null>(null);

    const selected = ALL_OPTIONS.find(o => o.value === value) ?? ALL_OPTIONS[0];

    return (
        <>
            <Button
                size="small"
                variant="outlined"
                endIcon={<KeyboardArrowDownIcon />}
                onClick={e => setAnchor(e.currentTarget)}
                sx={{ textTransform: 'none', minWidth: 130, justifyContent: 'space-between' }}
            >
                {selected.label}
            </Button>

            <Popover
                open={Boolean(anchor)}
                anchorEl={anchor}
                onClose={() => setAnchor(null)}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'left' }}
            >
                <div style={{ padding: 16, maxWidth: 320 }}>
                    {MODEL_GROUPS.map(group => (
                        <div key={group.label} style={{ marginBottom: 12 }}>
                            <Typography variant="caption" color="text.secondary" style={{ display: 'block', marginBottom: 4, fontWeight: 600, textTransform: 'uppercase', letterSpacing: 0.5, fontSize: 11 }}>
                                {group.label}
                            </Typography>
                            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4 }}>
                                {group.options.map(opt => (
                                    <Tooltip key={opt.value} title={opt.hint} placement="top" arrow>
                                        <Chip
                                            label={opt.label}
                                            size="small"
                                            onClick={() => { onChange(opt.value); setAnchor(null); }}
                                            color={opt.value === value ? 'primary' : 'default'}
                                            variant={opt.value === value ? 'filled' : 'outlined'}
                                            sx={{ cursor: 'pointer' }}
                                        />
                                    </Tooltip>
                                ))}
                            </div>
                        </div>
                    ))}
                </div>
            </Popover>
        </>
    );
};

export default ModelPicker;
