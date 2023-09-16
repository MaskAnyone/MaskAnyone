import createSagaMiddleware from 'redux-saga';
import {applyMiddleware, createStore} from 'redux';
import {rootReducer} from "./reducer";
import {composeWithDevTools} from "@redux-devtools/extension";
import rootSaga from "./saga";

const sagaMiddleware = createSagaMiddleware();

export const store = createStore(
    rootReducer,
    composeWithDevTools(applyMiddleware(sagaMiddleware)),
);

sagaMiddleware.run(rootSaga);
