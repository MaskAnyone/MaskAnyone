FROM nginx:1.25-alpine

RUN rm /etc/nginx/conf.d/default.conf

RUN apk update \
    && apk add --no-cache \
       git \
       pcre \
       pcre-dev \
       openssl \
       wget \
       g++ \
       zlib-dev \
       make \
       brotli-dev # Add Brotli libraries

# Setup nginx brotli
RUN mkdir /brotli \
    && cd /brotli \
    && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxvf nginx-${NGINX_VERSION}.tar.gz \
    && git clone https://github.com/google/ngx_brotli.git \
    && cd /brotli/ngx_brotli \
    && git checkout 6e975bcb015f62e1f303054897783355e2a877dc \
    && git submodule update --init \
    && cd /brotli/nginx-${NGINX_VERSION} \
    && ./configure --with-compat --add-dynamic-module=../ngx_brotli \
    && make modules \
    && cp objs/*.so /etc/nginx/modules \
    && rm -rf /ngx_brotli \
    && echo 'load_module modules/ngx_http_brotli_filter_module.so;load_module modules/ngx_http_brotli_static_module.so;' | cat - /etc/nginx/nginx.conf > temp \
    && mv temp /etc/nginx/nginx.conf

COPY ./docker_build/frontend/conf/* /etc/nginx/conf.d

COPY ./frontend/build /var/www

WORKDIR /var/www
