# Dockerfile.glibc229
FROM node:14-bullseye

WORKDIR /app

COPY . .

RUN npm install

EXPOSE 9090

CMD ["npm", "start"]
