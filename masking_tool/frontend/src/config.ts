interface ConfigType {
    environment: 'development'|'production';
    app: {
        version: string;
        name: string;
    };
    api: {
        baseUrl: string;
    };
    upload: {
        maxSize: number;
        accept: Record<string, string[]>;
        concurrency: number;
    };
}

const Config: ConfigType = {
    environment: process.env.REACT_APP_ENV! as 'development'|'production',
    app: {
        version: process.env.REACT_APP_VERSION!,
        name: process.env.REACT_APP_NAME!,
    },
    api: {
        baseUrl: window.location.origin + '/api',
    },
    upload: {
        maxSize: 200_000_000, /* 200 MB */
        accept: {
            'video/mp4': ['.mp4'],
        },
        concurrency: 3,
    },
};

export default Config;
