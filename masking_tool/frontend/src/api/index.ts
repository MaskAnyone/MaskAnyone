import axios, {AxiosRequestConfig, AxiosResponse} from 'axios';
import Config from "../config";

const configuredAxios = axios.create({
    baseURL: Config.api.baseUrl,
});

const sendApiRequest = async (config: AxiosRequestConfig): Promise<AxiosResponse> => {
    return configuredAxios(config);
};

const Api = {
    fetchVideos: async (): Promise<any[]> => {
        const result = await sendApiRequest({
            url: 'videos',
            method: 'get',
        });

        return result.data.videos;
    },
    fetchVideoResults: async (original_video_name: string): Promise<string[]> => {
        const result = await sendApiRequest({
            url: `results/${original_video_name}`,
            method: 'get'
        })
        return result.data.results
    },
    fetchResultPreview: async (
        original_video_name: string,
        result_video_name: string
    ): Promise<any[]> => {
        const result = await sendApiRequest({
            url: `results/preview/${original_video_name}/${result_video_name}`,
            method: 'get'
        })
        return result.data.image
    },
    maskVideo: async (
        videoName: string,
        extractPersonOnly: boolean,
        headOnlyHiding: boolean,
        hidingStrategy: number,
        headOnlyMasking: boolean,
        maskCreationStrategy: number,
        detailedFingers: boolean,
        detailedFaceMesh: boolean
    ): Promise<void> => {
        await sendApiRequest({
            url: 'run',
            method: 'post',
            data: {
                video: videoName,
                extract_person_only: extractPersonOnly,
                head_only_hiding: headOnlyHiding,
                hiding_strategy: hidingStrategy,
                head_only_masking: headOnlyMasking,
                mask_creation_strategy: maskCreationStrategy,
                detailed_fingers: detailedFingers,
                detailed_facemesh: detailedFaceMesh
            }
        });
    },
};

export default Api;
