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
- `pgAdmin` will be available at `localhost:8081` after spinning up the database.
- Default database name is `qrmos`.

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

Export env variables to current process:
```bash
export APP_ENV=prod
```
- Default environment variables are specified in `backend/.default.env`.
- For production code, default env variables will be read from `build/.default.env`.
- Export prod env variables accordingly in order to run production code.

Run production code:
```bash
cd build
./main
```
