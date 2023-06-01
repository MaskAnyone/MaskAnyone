FROM nginx:1.21-alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY ./conf/* /etc/nginx/conf.d

COPY ./ssl/* /etc/ssl-certificate/

WORKDIR /var/www
