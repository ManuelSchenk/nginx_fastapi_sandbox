
# About the Project

This is a sandbox to play around with:
* docker swarm 
* nginx as a reverse proxy
* docker registry
* uvicorn/fastAPI as dummy Service/Application

It will deploy the service globally over all swarm nodes using the registry to provide the images.
Nginx serves as a central entry point for all the services deployed to the worker.


# Prerequisites

1) For **NGINX Authentication**, create an `.htpasswd` File that stores your user credentials. On Linux, you can use the `htpasswd` utility from the `apache2-utils` package:
```bash
# Install apache2-utils if you don't have it 
sudo apt-get install apache2-utils  
# Create the .htpasswd file with a new user (e.g., 'user1') 
sudo htpasswd -c /etc/nginx/.htpasswd cse2lr
```
2) For **NGINX SSL Termination**, create a SSL certificate and place it in the `certs` folder:
`openssl req -x509 -nodes -days 356 -newkey rsa:2048 -keyout nginx-selfsigned.key -out nginx-selfsigned.crt`
3) the used local registry dont use TSL (insecure) 
therefore you have to allow docker to use it with adding the following into your `/etc/docker/daemon.json`:
```json
{
  "proxies": {
        ...
        "no-proxy": "...,IP_of_manager_node"
  },
  "insecure-registries": ["IP_of_manager_node:5000"],
  ...
}
```
Also if you use a local proxy add `registry` into no-proxy!
Afterwards restart docker: `sudo service docker restart`
This must be done on all nodes!



# How to deploy

1) adapt the `nginx.conf` file if needed
2) run the **Makefile** in the project directory
3) check the if the stack is running as expected:
```bash
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
docker stack services myswarm
docker stack ps myswarm --no-trunc
# to check the registry
curl http://localhost:5000/v2/_catalog
# to see the logs
docker service ls
docker service logs --follow myswarm_fastapi_swarm
docker service inspect myswarm_fastapi_swarm --pretty
# check nginx live (check if DNS works properly)
docker exec -it <nginx_container_id> sh
getent hosts fastapi_swarm
getent hosts fastapi_backup
```
4) check if its reachable/working with **posting** (Dont forget to add a basic http auth header) or use **wget**:
`wget --progress=dot:mega --user=your_username --password=your_password--no-check-certificate -O - https://manus-swarm.com/health_check` (-O - suppresses the file output and show it directly on stdout and --progress=dot:mega is needed to show the respond message)


# Usage

When the first deployment was successfull and the image of fastapi was pushed to the registry you can start the stack/swarm without the initialisation with:
`make stack_deploy`