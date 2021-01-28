FROM nginx:1.19.6-alpine

EXPOSE 80

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

COPY ./app/dist/app /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]