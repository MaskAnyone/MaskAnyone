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
};

export default Api;
