import {ReduxState} from "../reducer";

const initialized = (state: ReduxState): boolean => state.auth.initialized;
const user = (state: ReduxState) => state.auth.user;

const AuthSelector = {
    initialized,
    user,
};

export default AuthSelector;
