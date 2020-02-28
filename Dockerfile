FROM openresty/openresty:1.15.8.2-7-alpine-fat

RUN apk add openssl-dev git
RUN apk add --no-cache curl perl
RUN luarocks install --server=http://luarocks.org/dev lua-resty-template
RUN opm get spacewander/luafilesystem

WORKDIR /app

COPY templates /app/templates
COPY style /app/style
COPY img /app/img

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

