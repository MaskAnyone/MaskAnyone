import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {AuthProviderInitializedPayload, UserAuthenticatedPayload} from "../actions/authEvent";
import {User} from "../types/User";

export interface AuthState {
    initialized: boolean;
    user: null|User;
}

export const authInitialState: AuthState = {
    initialized: false,
    user: null,
};

/* eslint-disable max-len */
export const authReducer = handleActions<AuthState, any>(
    {
        [Event.Auth.authProviderInitialized.toString()]: (state, action: Action<AuthProviderInitializedPayload>): AuthState => {
            return {
                ...state,
                initialized: true,
            };
        },
        [Event.Auth.userAuthenticated.toString()]: (state, action: Action<UserAuthenticatedPayload>): AuthState => {
            return {
                ...state,
                user: action.payload.user,
            };
        },
    },
    authInitialState,
);
