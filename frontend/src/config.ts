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
    keycloak: {
        baseUrl: string;
        realm: string;
        clientId: string;
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
    keycloak: {
        baseUrl: `${window.location.origin}/auth`,
        realm: process.env.REACT_APP_KEYCLOAK_REALM!,
        clientId: process.env.REACT_APP_KEYCLOAK_CLIENT_ID!,
    },
};

export default Config;
