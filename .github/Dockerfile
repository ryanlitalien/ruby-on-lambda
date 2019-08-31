FROM node:lts-alpine

# install simple http server for serving static content
RUN npm install -g yarn

# make the 'app' folder the current working directory
WORKDIR /app

# copy all vue files
COPY site /app/

# install project dependencies
RUN yarn install

# copy project files and folders to the current working directory (i.e. 'app' folder)
#COPY . .
