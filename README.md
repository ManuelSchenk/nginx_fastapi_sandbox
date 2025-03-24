



# About the Project

This is a sandbox to play around with docker swarm and nginx as a reverse proxy



# How to use

1) config the `nginx.conf` file  
2) run the `docker-compose.yaml` with `docker compose up --build`
3) check if its working with `wget --no-check-certificate -q -O - https://manus-swarm.com/health_check` (-q is for quite and -O - suppresses the file output and show it directly on stdout)