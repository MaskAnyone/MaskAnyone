import {Divider, Menu, MenuItem} from "@mui/material";
import {useSelector} from "react-redux";
import Selector from "../../../state/selector";
import Config from "../../../config";
import KeycloakAuth from "../../../keycloakAuth";

interface DownloadMenuProps {
    videoId: string;
    resultVideoId?: string;
    hasResults?: boolean;
    anchorEl: HTMLElement|null;
    onClose: () => void;
}

const DownloadMenu = (props: DownloadMenuProps) => {
    const downloadableResultFileLists = useSelector(Selector.Video.downloadableResultFileLists);

    const downloadableResultFiles = downloadableResultFileLists[props.resultVideoId || ''] || [];
    const open = Boolean(props.anchorEl);

    const downloadOriginalVideo = () => {
        window.open(`/api/videos/${props.videoId}/download?token=${KeycloakAuth.getToken()}`, '_blank');
        props.onClose();
    };

    const downloadResultVideo = () => {
        window.open(`/api/videos/${props.videoId}/results/${props.resultVideoId}/download?token=${KeycloakAuth.getToken()}`, '_blank');
        props.onClose();
    };

    // Archives are built on the server: masked video, data files,
    // masking_config.json and a README, named after the result.
    const downloadResultArchive = () => {
        window.open(`${Config.api.baseUrl}/videos/${props.videoId}/results/${props.resultVideoId}/download/zip?token=${KeycloakAuth.getToken()}`, '_blank');
        props.onClose();
    };

    const downloadAllResultsArchive = () => {
        window.open(`${Config.api.baseUrl}/videos/${props.videoId}/results-zip?token=${KeycloakAuth.getToken()}`, '_blank');
        props.onClose();
    };

    return (
        <Menu
            anchorEl={props.anchorEl}
            open={open}
            onClose={props.onClose}
        >
            {props.resultVideoId && <MenuItem onClick={downloadResultArchive}>This result, all files (.zip)</MenuItem>}
            {props.hasResults && <MenuItem onClick={downloadAllResultsArchive}>All results of this video (.zip)</MenuItem>}
            {(props.resultVideoId || props.hasResults) && <Divider />}
            <MenuItem onClick={downloadOriginalVideo}>Original Video</MenuItem>
            {props.resultVideoId && <MenuItem onClick={downloadResultVideo}>Result Video</MenuItem>}
            {downloadableResultFiles.map((file) => (
                <MenuItem
                    key={file.id}
                    onClick={() => {
                        window.open(Config.api.baseUrl + file.url + `?token=${KeycloakAuth.getToken()}`, '_blank');
                        props.onClose();
                    }}
                    children={file.title}
                />
            ))}
        </Menu>
    );
};

export default DownloadMenu;
