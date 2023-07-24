
const Paths = {
    videos: '/videos',
    videoDetails: '/videos/:videoId',
    videoRunMasking: 'videos/mask',
    resultVideoDetails: '/videos/:videoId/results/:resultVideoId',
    runs: '/runs',
    presets: '/presets',
    workers: '/workers',

    makeVideoDetailsUrl: (videoId: string) => Paths.videoDetails
        .replace(':videoId', videoId),
    makeResultVideoDetailsUrl: (videoId: string, resultVideoId: string) => Paths.resultVideoDetails
        .replace(':videoId', videoId)
        .replace(':resultVideoId', resultVideoId),
};

export default Paths;
