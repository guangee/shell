FROM mongo:7.0.37
ADD mongo-init.js /docker-entrypoint-initdb.d/10-app-user.js
ADD mongod.conf /etc/mongod.conf
CMD mongod --config /etc/mongod.conf