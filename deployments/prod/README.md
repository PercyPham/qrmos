# QRMOS Deployment

## Setup Instruction

Using DigitalOcean's droplet, with these configurrations:
- OS: `Ubuntu 20.04 (LTS) x64`
- Plan: `Basic` > `1GB CPU, 25GB SSD, 1000GB transfer`
- Datacenter: `Singapore`
- Authentication: `SSH keys`
- Hostname: `qrmos-prod`

<details>
<summary>[Local] Setup SSH to connect prod server</summary>

Modify `~/.ssh/config`: add these in file:
```
Host qrmos_prod
    HostName <server.ip>
    User <server.user>
    IdentityFile <server.pri.key.path.on.local>
```

SSH to prod server:
```
ssh qrmos_prod
```
</details>

### Prod server setup

[Install Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)

[Install Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04)

<details>
<summary>Setup Database</summary>

Make a copy of [docker-compose.prod.yaml](./docker-compose.prod.yaml) to prod server at `~/`.

Create an prod env file and edit docker-compose env variables.
```
touch ~/.prod.env
```

Template of `.prod.env`:
```
MYSQL_ROOT_PASSWORD=xxx
```

Run docker-compose:
```
docker-compose -f docker-compose.prod.yaml --env-file .prod.env up -d
```

After a few minutes, should be able to connect to `phpmyadmin` via `${droplet-ip}:8081`. Login using:
```
user: root
password: ${MYSQL_ROOT_PASSWORD}
```

Run SQL script [here](../../backend/init/db/schemas.sql) to initalize the `qrmos` database.

</details>

[Install Golang](https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-20-04)

- Note: install version 1.17.5 with below commands

```
curl -OL https://golang.org/dl/go1.17.5.linux-amd64.tar.gz

sudo tar -C /usr/local -xvf go1.17.5.linux-amd64.tar.gz
```

Make a copy of [build_backend.sh](./build_backend.sh) to `~/.build_backend.sh` on prod server.

Make `~/.build_backend.sh` executable:
```
chmod +x ~/.build_backend.sh
```

Clone this repo on prod server (must setup `git` first):
```
git clone git@github.com:PercyPham/qrmos.git ~/qrmos
```

Create `~/.env` for server's environment variables:
```
touch ~/.env
```
- This file contains all environment variables for backend app running on prod server. Refer to [.default.env](../../backend/.default.env) for more information.
