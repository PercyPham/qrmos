.PHONY: dev_db_up dev_db_down dev_db_clean dev_run_backend dev_run_frontend build_clean build_backend build_frontend build run_built deploy

# Color section
# Ref: https://qastack.vn/programming/5947742/how-to-change-the-output-color-of-echo-in-linux
GREEN=\033[0;32m
NC=\033[0m # No Color


##################### DEVELOPMENT: DATABASE ######################

dev_db_up:
	@docker compose -f deployments/dev/docker-compose.dev.yaml up -d

dev_db_down:
	@docker compose -f deployments/dev/docker-compose.dev.yaml down

dev_docker_volume_name := $(shell docker volume ls -q | grep "qrmos_db_volume")
dev_db_clean:
	@if [ ! -z "$(dev_docker_volume_name)" ]; then\
		echo "$(GREEN)> Removing docker volume ...$(NC)";\
		docker volume rm $(dev_docker_volume_name);\
	fi
	@echo "$(GREEN)> Cleaned!$(NC)";

##################### DEVELOPMENT: RUN ###########################

dev_run_backend:
	@cd backend && go run cmd/server/main.go

dev_run_frontend:
	@cd frontend && flutter run -d chrome

##################### PRODUCTION: BUILD ##########################

build_clean:
	@rm -rf build
	@mkdir build

build_backend:
	@cd backend && go build -o ../build/main cmd/server/main.go
	@cp backend/.default.env build/.default.env

build_frontend:
	@cd frontend && flutter build web --base-href=/web/
	@cp -R frontend/build/web build/web

build: build_clean
	@echo "$(GREEN)> Building backend ...$(NC)"
	@make build_backend

	@echo "$(GREEN)> Building frontend ...$(NC)"
	@make build_frontend

run_built:
	@cd build &&\
		echo "APP_ENV=staging" > .env &&\
		./main


##################### PRODUCTION: DEPLOY #########################

SERVER_PROD_SSH?=qrmos_prod

deploy: build
	@echo "$(GREEN)> Building backend on prod server ...$(NC)"
	@ssh -t ${SERVER_PROD_SSH} '\
		rm -rf ~/app;\
		~/build_backend.sh;\
		cp -r ~/qrmos/build ~/app;\
		cp ~/.env ~/app/.env'

	@echo "$(GREEN)> Copying built web to prod server ...$(NC)"
	@scp -r build/web ${SERVER_PROD_SSH}:app/web

	@echo "$(GREEN)> Restarting prod server ...$(NC)"
	@ssh ${SERVER_PROD_SSH} '\
		mv ~/app/main ~/app/qrmos;\
		killall qrmos;\
		cd ~/app; ./qrmos >out.log 2>err.log &'

	@echo ""
	@echo "$(GREEN)> Done!$(NC)"
	@echo ""
