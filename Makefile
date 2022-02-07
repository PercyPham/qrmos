dev_db_up:
	@docker compose -f backend/deployments/dev/docker-compose.dev.yaml up -d

dev_db_down:
	@docker compose -f backend/deployments/dev/docker-compose.dev.yaml down

dev_docker_volume_name := $(shell docker volume ls -q | grep "qrmos_db_volume")
dev_db_clean:
	@if [ ! -z "$(dev_docker_volume_name)" ]; then\
		echo "Removing docker volume ...";\
		docker volume rm $(dev_docker_volume_name);\
	fi
	@echo "Cleaned!";

dev_run_backend:
	@cd backend && go run cmd/server/main.go

dev_run_frontend:
	@cd frontend && flutter run

.PHONY: dev_db_up dev_db_down dev_db_clean dev_run_backend dev_run_frontend
