# QRMOS Deployment

## Setup Instruction

Using DigitalOcean's droplet, with configurration:
- OS: `Ubuntu 20.04 (LTS) x64`
- Plan: `Basic` > `1GB CPU, 25GB SSD, 1000GB transfer`
- Datacenter: `Singapore`
- Authentication: `SSH keys`
- Hostname: `qrmos-prod`

[Install Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)

[Install Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04)

<details>
<summary>Setup Database</summary>

Make a copy of [docker-compose.prod.yaml](./docker-compose.prod.yaml).

Create an prod env file and edit docker-compose env variables.
```
touch .prod.env
```

Run docker-compose:
```
docker-compose -f docker-compose.prod.yaml --env-file .prod.env up -d
```

</details>

After few minutes, should be able to connect to `phpmyadmin` via `${droplet-ip}:8081`

Run SQL script [here](../../backend/init/db/schemas.sql) to initalize the `qrmos` database

[Install Golang](https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04)

- Note: install version 1.17.5 with below commands

```
curl -OL https://golang.org/dl/go1.17.5.linux-amd64.tar.gz

sudo tar -C /usr/local -xvf go1.17.5.linux-amd64.tar.gz
```
