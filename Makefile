.PHONY: dev_db_up dev_db_down dev_db_clean dev_run_backend dev_run_frontend build

# Color section
# Ref: https://qastack.vn/programming/5947742/how-to-change-the-output-color-of-echo-in-linux
GREEN=\033[0;32m
NC=\033[0m # No Color


##################### DEVELOPMENT: DATABASE ######################

dev_db_up:
	@docker compose -f backend/deployments/dev/docker-compose.dev.yaml up -d

dev_db_down:
	@docker compose -f backend/deployments/dev/docker-compose.dev.yaml down

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

build:
	@echo "$(GREEN)> Emptying 'build' folder ...$(NC)"
	@rm -rf build
	@mkdir build

	@echo "$(GREEN)> Building backend ...$(NC)"
	@cd backend && go build -o ../build/main cmd/server/main.go
	@cp backend/.default.env build/.default.env

	@echo "$(GREEN)> Building frontend ...$(NC)"
	@cd frontend && flutter build web --base-href=/web/
	@cp -R frontend/build/web build/web

	@echo ""
	@echo "$(GREEN)> Done!$(NC)"
	@echo ""
