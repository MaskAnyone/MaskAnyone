import axios, {AxiosRequestConfig, AxiosResponse} from 'axios';
import Config from "../config";
import {ApiFetchJobsResponse, ApiFetchVideosResponse} from "./types";
import { RunParams } from '../state/types/Run';

const configuredAxios = axios.create({
    baseURL: Config.api.baseUrl,
});

const sendApiRequest = async (config: AxiosRequestConfig): Promise<AxiosResponse> => {
    return configuredAxios(config);
};

const Api = {
    fetchVideos: async (): Promise<ApiFetchVideosResponse> => {
        const result = await sendApiRequest({
            url: 'videos',
            method: 'get',
        });

        return result.data;
    },
    fetchVideoResults: async (videoId: string): Promise<string[]> => {
        const result = await sendApiRequest({
            url: `videos/${videoId}/results`,
            method: 'get'
        });

        return result.data.results
    },
    fetchResultPreview: async (
        video_id: string,
        result_video_id: string
    ): Promise<any[]> => {
        const result = await sendApiRequest({
            url: `videos/${video_id}/results/${result_video_id}/preview`,
            method: 'get'
        });

        return result.data.image
    },
    fetchJobs: async (): Promise<ApiFetchJobsResponse> => {
        const result = await sendApiRequest({
            url: 'jobs',
            method: 'get',
        });

        return result.data;
    },
    createBasicMaskingJob: async (
        id: string,
        videoId: string,
        runData: RunParams
    ): Promise<void> => {
        await sendApiRequest({
            url: 'jobs/create',
            method: 'post',
            data: {
                id,
                run_data: runData,
                video_id: videoId,
            }
        });
    },
    requestVideoUpload: async (videoId: string, videoName: string): Promise<void> => {
        await sendApiRequest({
            url: 'videos/upload/request',
            method: 'post',
            data: {
                video_id: videoId,
                video_name: videoName,
            },
        });
    },
    uploadVideo: async (
        videoId: string,
        fileContent: ArrayBuffer,
        onUploadProgress: (percentage: number) => void,
    ): Promise<void> => {
        await sendApiRequest({
            url: `/videos/upload/${videoId}`,
            method: 'post',
            data: fileContent,
            headers: { 'Content-Type': 'application/octet-stream' },
            onUploadProgress: progressEvent => {
                const percentComplete = Math.round((progressEvent.loaded * 100) / progressEvent.total!);
                onUploadProgress(percentComplete);
            },
        });
    },
    finalizeVideoUpload: async (videoId: string): Promise<void> => {
        await sendApiRequest({
            url: 'videos/upload/finalize',
            method: 'post',
            data: {
                video_id: videoId,
            },
        });
    },
};

export default Api;
