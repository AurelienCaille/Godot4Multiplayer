FROM node:alpine AS node-builder

WORKDIR /backend

COPY package*.json ./
COPY tsconfig.json ./
COPY src src

RUN npm install
RUN npx tsc

FROM heroiclabs/nakama:3.16.0
WORKDIR /nakama
RUN mkdir data/build
COPY --from=node-builder /backend/build data/build
COPY local.yml data/local.yml