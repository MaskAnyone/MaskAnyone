import { Box, Divider, Popover, Typography } from "@mui/material";
import { Chip32, Cpu32, DataCheck32, DataError32, HardDisk32, Memory32, Warning32 } from '@carbon/icons-react';

interface SystemResources {
    gpu: { name: string; vram_gb: number } | null;
    ram_total_gb: number | null;
    cpu_model: string | null;
    cpu_count: number | null;
    disk_free_gb: number | null;
    services: Record<string, boolean>;
}

interface Props {
    anchorEl: HTMLElement | null;
    onClose: () => void;
    resources: SystemResources | null;
}

const mono = { fontFamily: '"IBM Plex Mono", monospace', fontSize: '0.75rem' };

const Row = ({ icon, label, value, ok }: { icon: React.ReactNode; label: string; value: string; ok?: boolean }) => (
    <Box component="div" sx={{ display: 'flex', alignItems: 'center', gap: 1.5, py: 0.75 }}>
        <Box component="div" sx={{ color: ok === false ? 'error.main' : ok === true ? 'success.main' : 'text.secondary', display: 'flex' }}>
            {icon}
        </Box>
        <Box component="div" sx={{ flex: 1 }}>
            <Typography variant="caption" color="text.secondary" sx={mono}>{label}</Typography>
            <Typography variant="body2" sx={{ ...mono, fontWeight: 500 }}>{value}</Typography>
        </Box>
    </Box>
);

const SERVICE_LABELS: Record<string, string> = {
    sam2: 'SAM2',
    rtmpose: 'RTMPose',
    openpose: 'OpenPose',
};

const SystemStatusPopover = ({ anchorEl, onClose, resources }: Props) => {
    const open = Boolean(anchorEl);

    return (
        <Popover
            open={open}
            anchorEl={anchorEl}
            onClose={onClose}
            anchorOrigin={{ vertical: 'bottom', horizontal: 'left' }}
            transformOrigin={{ vertical: 'top', horizontal: 'left' }}
            PaperProps={{ sx: { p: 2, minWidth: 300, maxWidth: 380 } }}
        >
            <Typography variant="subtitle2" sx={{ ...mono, mb: 1, letterSpacing: '0.05em', textTransform: 'uppercase', color: 'text.secondary' }}>
                System Status
            </Typography>

            {/* Hardware */}
            <Row
                icon={<Chip32 size={18} />}
                label="GPU"
                value={resources?.gpu ? `${resources.gpu.name} — ${resources.gpu.vram_gb} GB VRAM` : 'Not detected'}
                ok={resources?.gpu ? true : false}
            />
            <Row
                icon={<Memory32 size={18} />}
                label="RAM"
                value={resources?.ram_total_gb ? `${resources.ram_total_gb} GB` : '—'}
            />
            <Row
                icon={<Cpu32 size={18} />}
                label="CPU"
                value={resources?.cpu_model
                    ? `${resources.cpu_model.replace(/\(R\)|\(TM\)/g, '').replace(/\s+/g, ' ').trim()} · ${resources.cpu_count} cores`
                    : '—'}
            />
            <Row
                icon={<HardDisk32 size={18} />}
                label="Disk free"
                value={resources?.disk_free_gb != null ? `${resources.disk_free_gb} GB` : '—'}
                ok={resources?.disk_free_gb != null ? resources.disk_free_gb > 10 : undefined}
            />

            <Divider sx={{ my: 1.5 }} />

            {/* Services */}
            <Typography variant="caption" color="text.secondary" sx={{ ...mono, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                Services
            </Typography>
            {resources?.services && Object.entries(resources.services).map(([name, up]) => (
                <Row
                    key={name}
                    icon={up ? <DataCheck32 size={18} /> : <DataError32 size={18} />}
                    label={SERVICE_LABELS[name] ?? name}
                    value={up ? 'Online' : 'Offline'}
                    ok={up}
                />
            ))}
            {resources && Object.keys(resources.services ?? {}).length === 0 && (
                <Row icon={<Warning32 size={18} />} label="Services" value="Could not probe" />
            )}
        </Popover>
    );
};

export default SystemStatusPopover;
