import Keycloak, {KeycloakInitOptions} from 'keycloak-js';
import Config from "./config";

const keycloak = new Keycloak({
    url: Config.keycloak.baseUrl,
    realm: Config.keycloak.realm,
    clientId: Config.keycloak.clientId,
});

const keycloakInitOptions: KeycloakInitOptions = {
    onLoad: 'check-sso',
    silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
};

const KeycloakAuth = {
    initialize: (): Promise<boolean> => new Promise((resolve, reject) => {
        keycloak.init(keycloakInitOptions)
            .then(authenticated => resolve(authenticated))
            .catch(reason => reject(reason));
    }),
    refreshToken: (minValidity: number): Promise<void> => {
        return new Promise<void>((resolve, reject) => {
            keycloak.updateToken(minValidity)
                .then(() => resolve())
                .catch(() => reject());
        });
    },
    register: () => keycloak.register(),
    login: () => keycloak.login(),
    logout: () => keycloak.logout(),
    instance: keycloak,
};

export default KeycloakAuth;
