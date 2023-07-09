
const Paths = {
    videos: '/videos',
    videoDetails: '/videos/:videoId',
    resultVideoDetails: '/videos/:videoId/results/:resultVideoId',
    runs: '/runs',
    presets: '/presets',

    makeVideoDetailsUrl: (videoId: string) => Paths.videoDetails
        .replace(':videoId', videoId),
    makeResultVideoDetailsUrl: (videoId: string, resultVideoId: string) => Paths.resultVideoDetails
        .replace(':videoId', videoId)
        .replace(':resultVideoId', resultVideoId),
};

export default Paths;
