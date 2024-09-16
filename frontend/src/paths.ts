
const Paths = {
    videos: '/videos',
    videoDetails: '/videos/:videoId',
    videoRunMasking: 'videos/mask',
    videoMaskingEditor: '/videos/:videoId/mask',
    videoResultMaskingEditor: '/videos/:videoId/results/:resultVideoId/mask',
    resultVideoDetails: '/videos/:videoId/results/:resultVideoId',
    runs: '/runs',
    presets: '/presets',
    workers: '/workers',
    about: '/about',

    makeVideoDetailsUrl: (videoId: string) => Paths.videoDetails
        .replace(':videoId', videoId),
    makeVideoMaskingEditorUrl: (videoId: string) => Paths.videoMaskingEditor
        .replace(':videoId', videoId),
    makeResultVideoMaskingEditorUrl: (videoId: string, resultVideoId: string) => Paths.videoResultMaskingEditor
        .replace(':videoId', videoId)
        .replace(':resultVideoId', resultVideoId),
    makeResultVideoDetailsUrl: (videoId: string, resultVideoId: string) => Paths.resultVideoDetails
        .replace(':videoId', videoId)
        .replace(':resultVideoId', resultVideoId),
};

export default Paths;
