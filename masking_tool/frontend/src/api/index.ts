import axios, { AxiosRequestConfig, AxiosResponse } from 'axios';
import Config from "../config";
import {
    ApiFetchDownloadableResultFilesResponse,
    ApiFetchJobsResponse,
    ApiFetchResultVideosResponse,
    ApiFetchVideosResponse, ApiFetchWorkersResponse
} from "./types";
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
    fetchVideoResults: async (videoId: string): Promise<ApiFetchResultVideosResponse> => {
        const result = await sendApiRequest({
            url: `videos/${videoId}/results`,
            method: 'get'
        });

        return result.data;
    },
    fetchBlendshapes: async (jobId: string): Promise<any> => {
        const result = await sendApiRequest({
            url: `jobs/${jobId}/results/blendshapes`,
            method: 'get'
        });

        return result.data;
    },
    fetchDownloadableResultFiles: async (videoId: string, resultVideoId: string): Promise<ApiFetchDownloadableResultFilesResponse> => {
        const result = await sendApiRequest({
            url: `videos/${videoId}/results/${resultVideoId}/result-files`,
            method: 'get'
        });

        return result.data;
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
        resultVideoId: string,
        runData: RunParams
    ): Promise<void> => {
        await sendApiRequest({
            url: 'jobs/create',
            method: 'post',
            data: {
                id,
                run_data: runData,
                video_id: videoId,
                result_video_id: resultVideoId
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
    fetchWorkers: async (): Promise<ApiFetchWorkersResponse> => {
        const result = await sendApiRequest({
            url: 'workers',
            method: 'get',
        });

        return result.data;
    },
};

export default Api;
