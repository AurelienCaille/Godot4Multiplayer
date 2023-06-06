FROM node:alpine AS node-builder

WORKDIR /backend

COPY package*.json ./
RUN npm install
COPY tsconfig.json ./
COPY src/*.ts ./
RUN npx tsc

FROM heroiclabs/nakama:3.16.0
WORKDIR /nakama
RUN mkdir /nakama/data/modules/build/
COPY --from=node-builder /backend/build/*.js /nakama/data/modules/build/
COPY local.yml /nakama/data/