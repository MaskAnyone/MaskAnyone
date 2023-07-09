import SideBarItem from "./SideBarItem";
import {Video} from "../state/types/Video";
import Paths from "../paths";

interface SideBarVideoItemProps {
    video: Video;
    badge: number;
}

const SideBarVideoItem = (props: SideBarVideoItemProps) => {
    return (
        <SideBarItem
            key={props.video.name}
            url={Paths.makeVideoDetailsUrl(props.video.id)}
            title={`${props.video.name}`}
            subtitle={`${Math.round(props.video.videoInfo.duration)}s, ${props.video.videoInfo.frameWidth}x${props.video.videoInfo.frameHeight}`}
            videoId={props.video.id}
            badge={props.badge}
        />
    );
};

export default SideBarVideoItem;
