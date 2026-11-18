from uvicorn.workers import UvicornWorker

class UvicornProdWorker(UvicornWorker):
    CONFIG_KWARGS = {
        "root_path": "/api/",
        "proxy_headers": True,
    }
