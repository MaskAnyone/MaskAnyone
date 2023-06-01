interface ConfigType {
    environment: 'development'|'production';
    app: {
        version: string;
        name: string;
    };
    api: {
        baseUrl: string;
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
};

export default Config;
