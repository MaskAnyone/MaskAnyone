import {useEffect} from "react";
import Api from "../../api";
import {useDispatch} from "react-redux";
import Event from "../../state/actions/event";

const VideosPage = () => {
    const dispatch = useDispatch();

    useEffect(() => {
        Api.fetchVideos().then(videos => {
            dispatch(Event.Video.videoListFetched({ videoList: videos }));
        });
    }, []);

    return <div>test</div>;
};

export default VideosPage;
