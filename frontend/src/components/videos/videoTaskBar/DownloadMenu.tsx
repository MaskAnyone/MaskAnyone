import {Menu, MenuItem} from "@mui/material";
import {useSelector} from "react-redux";
import Selector from "../../../state/selector";
import Config from "../../../config";
import KeycloakAuth from "../../../keycloakAuth";

interface DownloadMenuProps {
    videoId: string;
    resultVideoId?: string;
    anchorEl: HTMLElement|null;
    onClose: () => void;
}

const DownloadMenu = (props: DownloadMenuProps) => {
    const downloadableResultFileLists = useSelector(Selector.Video.downloadableResultFileLists);

    const downloadableResultFiles = downloadableResultFileLists[props.resultVideoId || ''] || [];
    const open = Boolean(props.anchorEl);

    const downloadOriginalVideo = () => {
        window.open(`/api/videos/${props.videoId}/download?token=${KeycloakAuth.instance.token}`, '_blank');
        props.onClose();
    };

    const downloadResultVideo = () => {
        window.open(`/api/videos/${props.videoId}/results/${props.resultVideoId}/download?token=${KeycloakAuth.instance.token}`, '_blank');
        props.onClose();
    };

    return (
        <Menu
            anchorEl={props.anchorEl}
            open={open}
            onClose={props.onClose}
        >
            <MenuItem onClick={downloadOriginalVideo}>Original Video</MenuItem>
            {props.resultVideoId && <MenuItem onClick={downloadResultVideo}>Result Video</MenuItem>}
            {downloadableResultFiles.map((file) => (
                <MenuItem
                    key={file.id}
                    onClick={() => {
                        window.open(Config.api.baseUrl + file.url, '_blank');
                        props.onClose();
                    }}
                    children={file.title}
                />
            ))}
        </Menu>
    );
};

export default DownloadMenu;
