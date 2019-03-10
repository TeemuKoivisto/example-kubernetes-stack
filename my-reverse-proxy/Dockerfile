FROM nginx:1.15.9-alpine

LABEL maintainer="https://github.com/teemukoivisto"

ENV HTTP_PORT 80
ENV HTTPS_PORT 443

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/
COPY localhost.key localhost.crt dhparam4096.pem /root/certs/my-website/

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}
# Run the nginx without daemon to keep the process and the container bound together
# This way when nginx fails the container fails 
CMD ["nginx", "-g", "daemon off;"]