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
    getToken: () => keycloak.token,
    getTokenParsed: () => keycloak.tokenParsed,
};

/**
 * For local runtime mode we just override actual KeycloakAuth methods with dummy ones to act as if a user is logged in.
 */
export const switchToLocalAuthMode = () => {
    KeycloakAuth.initialize = () => Promise.resolve(true);
    KeycloakAuth.refreshToken = () => Promise.resolve();
    KeycloakAuth.register = () => Promise.resolve();
    KeycloakAuth.login = () => Promise.resolve();
    KeycloakAuth.logout = () => Promise.resolve();
    KeycloakAuth.getToken = () => '';
    KeycloakAuth.getTokenParsed = () => ({
        sub: '00000000-0000-0000-0000-000000000000',
        email: null,
        given_name: 'Local',
        family_name: null,
    });
};

export default KeycloakAuth;
