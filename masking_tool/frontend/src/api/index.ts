import axios, {AxiosRequestConfig, AxiosResponse} from 'axios';
import Config from "../config";
import {ApiFetchJobsResponse, ApiFetchVideosResponse} from "./types";

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
        extractPersonOnly: boolean,
        headOnlyHiding: boolean,
        hidingStrategy: number,
        headOnlyMasking: boolean,
        maskCreationStrategy: number,
        detailedFingers: boolean,
        detailedFaceMesh: boolean
    ): Promise<void> => {
        await sendApiRequest({
            url: 'jobs/create',
            method: 'post',
            data: {
                id,
                video_id: videoId,
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
