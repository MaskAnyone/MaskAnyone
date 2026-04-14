const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function (app) {
    app.use(
        '/api',
        createProxyMiddleware({
            target: 'https://localhost',
            changeOrigin: true,
            secure: false,  // self-signed cert on the proxy container
            // No pathRewrite — nginx handles /api/ → backend routing
        })
    );
};
