import SideBarItem from "./SideBarItem";
import { Video } from "../state/types/Video";
import Paths from "../paths";

interface SideBarVideoItemProps {
    video: Video;
    badge: number;
    anyChecked: boolean;
    checked: boolean;
    active: boolean;
    onCheckboxClicked: (videoId: string) => void;
}

const SideBarVideoItem = (props: SideBarVideoItemProps) => {
    return (
        <SideBarItem
            key={props.video.name}
            title={`${props.video.name}`}
            subtitle={`${Math.round(props.video.videoInfo.duration)}s, ${props.video.videoInfo.frameWidth}x${props.video.videoInfo.frameHeight}`}
            videoId={props.video.id}
            badge={props.badge}
            onCheckboxClicked={props.onCheckboxClicked}
            checked={props.checked}
            active={props.active}
            anyChecked={props.anyChecked}
            url={Paths.makeVideoDetailsUrl(props.video.id)}
        />
    );
};

export default SideBarVideoItem;
