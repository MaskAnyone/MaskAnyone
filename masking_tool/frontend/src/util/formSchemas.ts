import { RJSFSchema } from "@rjsf/utils";

export const blurFormSchemaSubject: RJSFSchema = {
  type: 'object',
  properties: {
    subjectDetection: {
      type: 'string',
      enum: ['Silhouette', 'BoundingBox'],
      default: 'Silhouette',
      description: 'Bounding box lays a bounding box over the subject for hiding, while silhouette hides the subject within its exact contours only.'
    },
    kernelSize: { type: 'integer', title: 'Kernel Size', default: 23, description: 'The Kernelsize for a Gaussion Filter'},
    extraPixels: {type: 'number', title: "Additional pixels", default: 0, description: "Additional pixels to lay around the detected subject to ensure even further that it is masked completely."}
  },
  dependencies: {
    subjectDetection: {
      oneOf: [
        {
          properties: {
            subjectDetection: {enum: ['Silhouette']},
            detectionModel: {
              type: 'string',
              enum: ['MediaPipe', 'Yolo'],
              default: 'MediaPipe',
            },
          }
        },
        {
          properties: {
            subjectDetection: {enum: ['BoundingBox']},
            detectionModel: {
              type: 'string',
              enum: [ 'Yolo'],
              default: 'Yolo',
            },
          }
        }
      ]
    },
  },
};

export const blackoutFormSchemaSubject: RJSFSchema = {
  type: 'object',
  properties: {
    subjectDetection: {
      type: 'string',
      enum: ['Silhouette', 'BoundingBox'],
      default: 'Silhouette',
      description: 'Bounding box lays a bounding box over the subject for hiding, while silhouette hides the subject within its exact contours only.'
    },
    color: { type: 'string', title: 'Masking color', default: "black", description: 'The color with which the background should be overlayed and hidden.'},
    extraPixels: {type: 'number', title: "Additional pixels", default: 0, description: "Additional pixels to lay around the detected subject to ensure even further that it is masked completely."}
  },
  dependencies: {
    subjectDetection: {
      oneOf: [
        {
          properties: {
            subjectDetection: {enum: ['Silhouette']},
            detectionModel: {
              type: 'string',
              enum: ['MediaPipe', 'Yolo'],
              default: 'MediaPipe',
            },
          }
        },
        {
          properties: {
            subjectDetection: {enum: ['BoundingBox']},
            detectionModel: {
              type: 'string',
              enum: [ 'Yolo'],
              default: 'Yolo',
            },
          }
        }
      ]
    },
  },
};

export const blurFormSchemaBG: RJSFSchema = {
    type: 'object',
    properties: {
      kernelSize: { type: 'integer', title: 'Kernel Size', default: 23, description: 'The Kernelsize for a Gaussion Filter'},
    },
};

export const blackoutFormSchemaBG: RJSFSchema = {
    type: 'object',
    properties: {
      color: { type: 'string', title: 'Masking color', default: "black", description: 'The color with which the background should be overlayed and hidden.'},
    },
};

export const skeletonFormSchema: RJSFSchema = {
  type: 'object',
  properties: {
    num_poses: { type: 'number', title: 'Num Subjects', default: 1, description: 'The maximum number of subjects which can be detected'},
    confidence: { type: 'number', title: 'Confidence', default: 1, description: 'The minimum confidence score for the detection to be considered successful.'},
  },
};

export const faceMeshFormSchema: RJSFSchema = {
  type: 'object',
  properties: {
    num_faces: { type: 'number', title: 'Num Subjects', default: 1, description: 'The maximum number of faces which can be detected'},
    confidence: { type: 'number', title: 'Confidence', default: 1, description: 'The minimum confidence score for the face detection to be considered successful.'},
  },
};