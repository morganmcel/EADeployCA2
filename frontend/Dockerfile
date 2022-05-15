FROM node:10.15.1

# Create dir for app code inside image => working dir for app
WORKDIR /usr/src/app

RUN curl "https://s3-us-gov-west-1.amazonaws.com/rds-downloads/rds-combined-ca-us-gov-bundle.pem" --output /etc/pki/ca-trust/source/anchors/rds-combined-ca-us-gov-bundle.pem \
&& curl "https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem" --output /etc/pki/ca-trust/source/anchors/rds-combined-ca-bundle.pem \
&& update-ca-trust \
&& update-ca-trust force-enable

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

# Note NOT copying entire working dir, ONLY copying the package.json files 
# This allows us to take advantage of cached Docker layers

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Copy app source
COPY . .

# App binds to port 22137 - the EXPOSE instruction maps it to the docker daemon
EXPOSE 22137

# Will run node fe-server.js as defined in package.json
CMD [ "npm", "start" ]