FROM node:11

WORKDIR /opt/3tier

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]
