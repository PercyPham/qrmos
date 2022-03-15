# QRMOS

HungpmSE00234x's FUNiX Capstone Project.

## Get Started

### Development

Development environment requirements:

- [Golang v1.17.5](https://go.dev/dl/)
- [Docker v20.10.10](https://www.docker.com/get-started)
- [Flutter - stable, v2.10.0](https://docs.flutter.dev/get-started/install)

<details>
  <summary>Database Preparation (MUST)</summary>

Spin up database:
```
make dev_db_up
```

- First time running will take a **few minutes** to complete. Please be patient.
- `phpMyAdmin` will be available at `localhost:8081` after spinning up the database.
- Default database name is `qrmos`.

After spinning up DB for the first time, we need to initialize data by running this command (**only once**):
```
make init_data
```
- This will add an `admin` user with `password` as password.

Shutdown database:
```
make dev_db_down
```

- Shuting down database doesn't remove data in database, when spin up again, data will still be available. To completely clean up everything, use the clean command below.

Clean up database:
```
make dev_db_clean
```

</details>
<br>

Run backend:
```
make dev_run_backend
```

Run frontend:
```
make dev_run_frontend
```

### Production

Build QRMOS:
```
make build
```
- Built files are located in `build` folder at root.


<details>
  <summary>Config env variables</summary>

Default environment variables are specified in `backend/.default.env`. It will be copied to `build` folder during building.

For production code, default env variables will be read from `.default.env`.
To ovewrite those env, create a `.env` file, and add env variable to it.

Or simple export env variables to current process, example:
```bash
export APP_ENV=prod
```
</details>

Run built code:
```bash
make run_built
```

### Deployment

Currently deployed to DigitalOcean's droplet. Read [here](deployments/prod/README.md) for setup instruction

[Optional] Push `main` branch to `origin` remote since prod's backend will be built based on this.
```
git push origin main
```

Deploy:
```
make deploy
```
