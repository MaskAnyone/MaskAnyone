import { RJSFSchema, UiSchema } from "@rjsf/utils";

export const blurFormSchemaSubject: RJSFSchema = {
  type: 'object',
  properties: {
    subjectDetection: {
      type: 'string',
      title: 'Subject Detection (Localization) Method',
      enum: ['silhouette', 'boundingbox'],
      default: 'silhouette',
      description: 'Bounding box lays a bounding box over the subject for hiding, while silhouette hides the subject within its exact contours only.'
    },
    detectionParams: {
      type: "object",
      properties: {
        numPoses: { type: 'number', title: 'Num Subjects', default: 1, description: 'The maximum number of subjects which can be detected' },
        confidence: { type: 'number', title: 'Confidence', default: 0.5, description: 'The minimum confidence score for the detection to be considered successful.' },
      }
    },
    hidingParams: {
      type: "object",
      properties: {
        kernelSize: { type: 'integer', title: 'Kernel Size', default: 23, description: 'The Kernelsize for a Gaussion Filter' },
        extraPixels: { type: 'number', title: "Additional pixels", default: 0, description: "Additional pixels to lay around the detected subject to ensure even further that it is masked completely." }
      }
    }
  },
  dependencies: {
    subjectDetection: {
      oneOf: [
        {
          properties: {
            subjectDetection: { enum: ['silhouette'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detects (localizes) the subject in the video.',
              type: 'string',
              enum: ['mediapipe', 'yolo'],
              default: 'mediapipe',
            },
          }
        },
        {
          properties: {
            subjectDetection: { enum: ['boundingBox'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detects (localizes) the subject in the video.',
              type: 'string',
              enum: ['yolo'],
              default: 'yolo',
            },
          }
        }
      ]
    },
  },
};

export const blurFormSchemaSubjectUI: UiSchema = {
  'ui:order': ['subjectDetection', 'detectionModel', 'detectionParams', 'hidingParams'],
};

export const blackoutFormSchemaSubject: RJSFSchema = {
  type: 'object',
  properties: {
    subjectDetection: {
      type: 'string',
      enum: ['silhouette', 'boundingbox'],
      default: 'silhouette',
      description: 'Bounding box lays a bounding box over the subject for hiding, while silhouette hides the subject within its exact contours only.'
    },
    detectionParams: {
      type: "object",
      properties: {
        numPoses: { type: 'number', title: 'Num Subjects', default: 1, description: 'The maximum number of subjects which can be detected' },
        confidence: { type: 'number', title: 'Confidence', default: 0.5, description: 'The minimum confidence score for the detection to be considered successful.' },
      }
    },
    hidingParams: {
      type: "object",
      properties: {
        color: { type: 'number', title: 'Masking color', default: 0, description: 'From 0 (black) to 255 white' },
        extraPixels: { type: 'number', title: "Additional pixels", default: 0, description: "Additional pixels to lay around the detected subject to ensure even further that it is masked completely." }
      }
    }
  },
  dependencies: {
    subjectDetection: {
      oneOf: [
        {
          properties: {
            subjectDetection: { enum: ['silhouette'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detect (localize) the subject in the video.',
              type: 'string',
              enum: ['mediapipe', 'yolo'],
              default: 'mediapipe',
            },
          }
        },
        {
          properties: {
            subjectDetection: { enum: ['boundingbox'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detect (localize) the subject in the video.',
              type: 'string',
              enum: ['yolo'],
              default: 'yolo',
            },
          }
        }
      ]
    },
  },
};

export const blackoutFormSchemaSubjectUI: UiSchema = {
  'ui:order': ['subjectDetection', 'detectionModel', 'detectionParams', 'hidingParams'],
};

export const inpaintFormSchemaSubject: RJSFSchema = {
  type: 'object',
  properties: {
    subjectDetection: {
      type: 'string',
      enum: ['silhouette', 'boundingbox'],
      default: 'silhouette',
      description: 'Bounding box lays a bounding box over the subject for hiding, while silhouette hides the subject within its exact contours only.'
    },
    detectionParams: {
      type: "object",
      properties: {
        numPoses: { type: 'number', title: 'Num Subjects', default: 1, description: 'The maximum number of subjects which can be detected' },
        confidence: { type: 'number', title: 'Confidence', default: 0.5, description: 'The minimum confidence score for the detection to be considered successful.' },
      }
    }
  },
  dependencies: {
    subjectDetection: {
      oneOf: [
        {
          properties: {
            subjectDetection: { enum: ['silhouette'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detect (localize) the subject in the video.',
              type: 'string',
              enum: ['mediapipe', 'yolo'],
              default: 'mediapipe',
            },
          }
        },
        {
          properties: {
            subjectDetection: { enum: ['boundingbox'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detect (localize) the subject in the video.',
              type: 'string',
              enum: ['yolo'],
              default: 'yolo',
            },
          }
        }
      ]
    },
  },
};

export const inpaintFormSchemaSubjectUI: UiSchema = {
  'ui:order': ['subjectDetection', 'detectionModel', 'detectionParams'],
};

export const blurFormSchemaBG: RJSFSchema = {
  type: 'object',
  properties: {
    subjectDetection: {
      type: 'string',
      title: 'Subject Detection',
      enum: ['silhouette', 'boundingbox'],
      default: 'silhouette',
      description: '!Only required if no subject masking is used for other video parts! \
        Bounding box lays a bounding box over the subject for hiding, while silhouette hides the subject within its exact contours only.'
    },
    kernelSize: { type: 'integer', title: 'Kernel Size', default: 23, description: 'The Kernelsize for a Gaussion Filter' },
  },
  dependencies: {
    subjectDetection: {
      oneOf: [
        {
          properties: {
            subjectDetection: { enum: ['silhouette'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detect (localize) the subject in the video.',
              type: 'string',
              enum: ['mediapipe', 'yolo'],
              default: 'mediapipe',
            },
          }
        },
        {
          properties: {
            subjectDetection: { enum: ['boundingbox'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detect (localize) the subject in the video.',
              type: 'string',
              enum: ['yolo'],
              default: 'yolo',
            },
          }
        }
      ]
    }
  }
};

export const blackoutFormSchemaBG: RJSFSchema = {
  type: 'object',
  properties: {
    subjectDetection: {
      type: 'string',
      title: 'Subject Detection',
      enum: ['silhouette', 'boundingbox'],
      default: 'silhouette',
      description: '!Only required if no subject masking is used for other video parts! \
        Bounding box lays a bounding box over the subject for hiding, while silhouette hides the subject within its exact contours only.'
    },
    color: { type: 'number', title: 'Masking color', default: 0, description: 'From 0 (black) to 255 white' },
  },
  dependencies: {
    subjectDetection: {
      oneOf: [
        {
          properties: {
            subjectDetection: { enum: ['silhouette'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detect (localize) the subject in the video.',
              type: 'string',
              enum: ['mediapipe', 'yolo'],
              default: 'mediapipe',
            },
          }
        },
        {
          properties: {
            subjectDetection: { enum: ['boundingbox'] },
            detectionModel: {
              title: 'AI-Model for Subject Detection',
              description: 'Pre-trained models that detect (localize) the subject in the video.',
              type: 'string',
              enum: ['yolo'],
              default: 'yolo',
            },
          }
        }
      ]
    }
  }
};

export const skeletonFormSchema: RJSFSchema = {
  type: 'object',
  properties: {
    maskingModel: { title: 'The model that should be used for creating a skeleton.', type: 'string', default: 'mediapipe', enum: ['mediapipe'] },
    numPoses: { type: 'number', title: 'Num Subjects', default: 1, description: 'The maximum number of subjects which can be detected' },
    confidence: { type: 'number', title: 'Confidence', default: 0.5, description: 'The minimum confidence score for the detection to be considered successful.' },
    timeseries: { type: 'boolean', title: 'Save output as timeseries in CSV', default: false },
  },
}

export const faceMeshFormSchema: RJSFSchema = {
  type: 'object',
  properties: {
    maskingModel: { title: 'The model that should be used for creating a face mesh.', type: 'string', default: 'mediapipe', enum: ['mediapipe'] },
    numFaces: { type: 'number', title: 'Num Subjects', default: 1, description: 'The maximum number of faces which can be detected' },
    confidence: { type: 'number', title: 'Confidence', default: 0.5, description: 'The minimum confidence score for the face detection to be considered successful.' },
    timeseries: { type: 'boolean', title: 'Save output as timeseries in CSV', default: false },
  },
};

export const bodyMeshFormSchema: RJSFSchema = {
  type: 'object',
  properties: {
    maskingModel: { title: 'The model that should be used for the body mesh.', type: 'string', default: 'vibe', enum: ['vibe'] },
    timeseries: { type: 'boolean', title: 'Save output as timeseries in CSV', default: false },
  },
};

export const rvcSchema: RJSFSchema = {
  type: 'object',
  properties: {
    mode: { type: 'string', title: 'Masking mode', default: 'manual', enum: ["manual", "auto"], description: 'Manual mode allows you to select the masking voice yourself. Auto mode will automatically find a voice that is most likely to deliver good results for the given speaker' },
  },
  dependencies: {
    mode: {
      oneOf: [
        {
          properties: {
            mode: { enum: ['manual'] },
            voice: {
              title: 'Masking Voice',
              description: 'The selected voice will replace the original voice of the speaker',
              type: 'string',
              enum: ['arianaGrande', 'kanyeWest', 'mrKrabs', 'donaldTrump'],
              default: 'arianaGrande',
            },
          }
        },
      ]
    }
  }
};

export const faceswapFormSchema: RJSFSchema = {
  type: 'object',
  properties: {
    sourceImage: { title: 'The face that should be used for replacement', type: 'string', default: 'neutral', enum: ['neutral'] },
    maskginModel: { title: 'The pretrained deep learning model that should be used to swap faces', type: 'string', default: 'roop', enum: ['roop'] },

  },
};