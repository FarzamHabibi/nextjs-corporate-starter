# Creating multi-stage build for production
FROM node:18-alpine as build
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1
#ENV NODE_ENV=development

WORKDIR /backend/opt/
COPY package.json yarn.lock ./
RUN yarn global add node-gyp
RUN yarn config set network-timeout 600000 -g && yarn install --production
ENV PATH /opt/node_modules/.bin:$PATH
WORKDIR /backend/opt/app
COPY . .
RUN yarn build
RUN yarn develop
RUN chown -R node:node /opt/app
USER node
EXPOSE 1337

WORKDIR /frontend/opt/
RUN yarn dev
RUN chown -R node:node /opt/app
USER node
EXPOSE 3000

CMD ["yarn dev"]