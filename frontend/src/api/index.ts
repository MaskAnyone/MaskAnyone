import axios, { AxiosRequestConfig, AxiosResponse } from 'axios';
import Config from "../config";
import {
    ApiFetchDownloadableResultFilesResponse,
    ApiFetchJobsResponse, ApiFetchPresetsResponse,
    ApiFetchResultVideosResponse,
    ApiFetchVideosResponse, ApiFetchWorkersResponse
} from "./types";
import { RunParams } from '../state/types/Run';
import KeycloakAuth from "../keycloakAuth";
import {PlatformMode} from "../state/types/Platform";

const configuredAxios = axios.create({
    baseURL: Config.api.baseUrl,
});

const sendApiRequest = async (config: AxiosRequestConfig): Promise<AxiosResponse> => {
    await KeycloakAuth.refreshToken(10);
    configuredAxios.defaults.headers.Authorization = 'Bearer ' + KeycloakAuth.getToken();

    return configuredAxios(config);
};

const Api = {
    fetchPlatformMode: async (): Promise<PlatformMode> => {
        const result = await configuredAxios({
            url: 'platform/mode',
            method: 'get',
        });

        return result.data.platform_mode;
    },
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
    deleteResultVideo: async (id: string): Promise<void> => {
        await sendApiRequest({
            url: `results/${id}/delete`,
            method: 'post',
        });
    },
    fetchBlendshapes: async (resultVideoId: string): Promise<any> => {
        const result = await sendApiRequest({
            url: `/results/${resultVideoId}/blendshapes`,
            method: 'get'
        });

        return result.data;
    },
    fetchMpKinematics: async (resultVideoId: string): Promise<any> => {
        const result = await sendApiRequest({
            url: `/results/${resultVideoId}/mp-kinematics`,
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
        videoIds: string[],
        resultVideoId: string,
        runData: RunParams
    ): Promise<void> => {
        await sendApiRequest({
            url: 'jobs/create',
            method: 'post',
            data: {
                id,
                run_data: runData,
                video_ids: videoIds,
                result_video_id: resultVideoId
            }
        });
    },
    deleteJob: async (id: string): Promise<void> => {
        await sendApiRequest({
            url: `jobs/${id}/delete`,
            method: 'post',
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
    fetchPresets: async (): Promise<ApiFetchPresetsResponse> => {
        const result = await sendApiRequest({
            url: 'presets',
            method: 'get',
        });

        return result.data;
    },
    createNewPreset: async (
        id: string,
        name: string,
        description: string,
        data: any,
        videoId: string,
        resultVideoId: string
    ): Promise<void> => {
        await sendApiRequest({
            url: 'presets/create',
            method: 'post',
            data: {
                id,
                name,
                description,
                data,
                video_id: videoId,
                result_video_id: resultVideoId,
            },
        });
    },
    deletePreset: async (id: string): Promise<void> => {
        await sendApiRequest({
            url: `presets/${id}/delete`,
            method: 'post',
        });
    },
    fetchPosePrompt: async (videoId: string): Promise<any> => {
        const result = await sendApiRequest({
            url: `prompts/${videoId}/pose`,
            method: 'get',
        });

        return result.data.pose_prompts;
    },
    fetchPosePromptSegmentation: async (videoId: string, posePrompts: [number, number, number][][]): Promise<any> => {
        const result = await sendApiRequest({
            url: `prompts/${videoId}/sam2`,
            method: 'post',
            data: {
                pose_prompts: posePrompts,
            },
            responseType: 'blob',
        });

        return result.data;

        // return result.data.pose_segmentation_prompts;
    }
};

export default Api;
