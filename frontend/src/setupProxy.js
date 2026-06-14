const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function (app) {
    app.use(
        '/api',
        createProxyMiddleware({
            target: 'http://localhost:8001',
            changeOrigin: true,
            pathRewrite: { '^/api': '' },
        })
    );
};
