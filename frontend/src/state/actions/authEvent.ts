import {createAction} from 'redux-actions';
import {User} from "../types/User";

const createAuthEvent = <T>(type: string) => createAction<T>('_E/AU/' + type);

export interface AuthProviderInitializedPayload {
}

export interface UserAuthenticatedPayload {
    user: User;
}

const AuthEvent = {
    authProviderInitialized: createAuthEvent<AuthProviderInitializedPayload>('AUTH_PROVIDER_INITIALIZED'),
    userAuthenticated: createAuthEvent<UserAuthenticatedPayload>('USER_AUTHENTICATED'),
};

export default AuthEvent;
