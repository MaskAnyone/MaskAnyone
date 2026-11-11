import { useState } from 'react';
import { Button, Chip, Popover, Tooltip, Typography } from '@mui/material';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';

interface ModelOption {
    value: string;
    label: string;
    hint: string;
    disabled?: boolean;
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
        label: 'Animal — in development',
        options: [
            { value: 'rtmpose_ap10k', label: 'AP-10K', hint: 'In development — not yet tested or tuned. HRNet-W32 on AP-10K (54 species).', disabled: true },
            { value: 'rtmpose_ap10k_w48', label: 'AP-10K W48', hint: 'In development — not yet tested or tuned. Larger HRNet-W48 backbone.', disabled: true },
            { value: 'rtmpose_ap10k_rtm', label: 'AP-10K RTMPose ★', hint: 'In development — not yet tested or tuned. RTMPose backbone on AP-10K.', disabled: true },
            { value: 'rtmpose_animalpose', label: 'AnimalPose', hint: 'In development — not yet tested or tuned. Trained on cat/dog/horse/sheep/cow.', disabled: true },
            { value: 'rtmpose_ak_mammal', label: 'Animal Kingdom (mammal)', hint: 'In development — not yet tested or tuned. Mammal-specific Animal Kingdom model.', disabled: true },
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
                                        {/* wrapper div lets the Tooltip fire even when the Chip is disabled */}
                                        <span>
                                            <Chip
                                                label={opt.label}
                                                size="small"
                                                onClick={opt.disabled ? undefined : () => { onChange(opt.value); setAnchor(null); }}
                                                color={opt.value === value ? 'primary' : 'default'}
                                                variant={opt.value === value ? 'filled' : 'outlined'}
                                                disabled={opt.disabled}
                                                sx={{ cursor: opt.disabled ? 'not-allowed' : 'pointer', opacity: opt.disabled ? 0.5 : 1 }}
                                            />
                                        </span>
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
