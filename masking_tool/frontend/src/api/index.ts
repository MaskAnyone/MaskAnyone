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
