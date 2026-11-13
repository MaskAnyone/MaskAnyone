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
    // Shown before the option label on the closed picker, e.g. "RTMPose M".
    family?: string;
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
        family: 'RTMPose',
        options: [
            { value: 'rtmpose_s', label: 'S', hint: 'Fastest, least accurate. Good for quick previews.' },
            { value: 'rtmpose_m', label: 'M', hint: 'Balanced speed and accuracy. Recommended default for humans.' },
            { value: 'rtmpose_l', label: 'L', hint: 'Most accurate for humans, slowest of the three.' },
        ],
    },
    {
        label: 'Human — MediaPipe',
        family: 'MediaPipe',
        options: [
            { value: 'mp_pose', label: 'Pose', hint: 'Full-body pose. Fast, CPU-friendly, good for single person.' },
            { value: 'mp_face', label: 'Face', hint: 'Face mesh — 468 facial landmarks.' },
            { value: 'mp_hand', label: 'Hands', hint: 'Hand landmarks — 21 keypoints per hand.' },
        ],
    },
    {
        label: 'Human — OpenPose',
        family: 'OpenPose',
        options: [
            { value: 'openpose', label: 'Body', hint: 'Classic BODY_25 keypoints. Good multi-person support.' },
            { value: 'openpose_body25b', label: 'BODY_25B', hint: 'Improved 25-keypoint model with better foot detection.' },
            { value: 'openpose_face', label: '+ Face', hint: 'Body keypoints plus facial detail. Heavier.' },
            { value: 'openpose_body_135', label: 'BODY_135', hint: 'Full body including hands and face. Most detailed, slowest.' },
        ],
    },
];

// Animal models (AP-10K, AnimalPose, Animal Kingdom) were removed from the
// picker: they did not work well enough. The worker still maps their
// rtmpose_* values, so they can be re-added here once they are usable.

const ALL_OPTIONS = MODEL_GROUPS.flatMap(g => g.options.map(o => ({
    ...o,
    buttonLabel: g.family ? `${g.family} ${o.label}` : o.label,
})));

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
                {selected.buttonLabel}
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
