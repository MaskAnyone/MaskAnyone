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
    maskVideo: async (videoName: string): Promise<void> => {
        await sendApiRequest({
            url: 'run',
            method: 'post',
            data: {
                video: videoName,
                extract_person_only: true,
                person_removal_strategy: 0,
                body_masking_strategy: 2,
                face_masking_strategy: 0,
            }
        });
    },
};

export default Api;
