



# About the Project

This is a sandbox to play around with docker swarm and nginx as a reverse proxy


# Prerequisites

1) create  an `.htpasswd` File. First, generate a file that stores your user credentials. On Linux, you can use the `htpasswd` utility from the `apache2-utils` package:
```bash
# Install apache2-utils if you don't have it 
sudo apt-get install apache2-utils  
# Create the .htpasswd file with a new user (e.g., 'user1') 
sudo htpasswd -c /etc/nginx/.htpasswd cse2lr
```
2) create a SSL certificate and place it in the `certs` folder:
`openssl req -x509 -nodes -days 356 -newkey rsa:2048 -keyout nginx-selfsigned.key -out nginx-selfsigned.crt`


# How to use

1) adapt the `nginx.conf` file according your needs
2) build the images with `docker compose -f docker-compose_remote_worker.yaml build`
3) run the `docker-compose.yaml` with **SWARM** using `docker stack deploy -c docker-compose.yaml myswarm`
4) check the stack
```bash
docker stack services myswarm
# to see the logs
docker service ls
docker service inspect myswarm_fastapi --pretty
docker service logs myswarm_fastapi
```
5) check if its working with **posting** or `wget --no-check-certificate -q -O - https://manus-swarm.com/health_check` (-q is for quite and -O - suppresses the file output and show it directly on stdout)
**HINT**: Dont forget to add a basic http auth header (user+pw)