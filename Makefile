WORKDIR		:= $(shell pwd)
DOCKER_IMGS	:= $(shell docker images -q)
DOCKER_CTRS	:= $(shell docker ps -aq)
DOCKER_VLMS	:= $(shell docker volume ls -q)

# Colors
RED			:=	$(shell tput -Txterm setaf 1)
GREEN		:=	$(shell tput -Txterm setaf 2)
BLUE		:=	$(shell tput -Txterm setaf 4)
RESET_COLOR	:=	$(shell tput -Txterm sgr0)

build:
	@cd $(WORKDIR)/srcs && docker compose up --build -d --wait
	@echo "\n$(GREEN)Successfully built and started all Docker images and containers! ✅$(RESET_COLOR)"

all: build

down:
	@echo "$(RED)Stopping compose stack...$(RESET_COLOR)"
	@cd $(WORKDIR)/srcs && docker compose down --remove-orphans || true

infos:
	@echo "$(GREEN)Docker Images:$(RESET_COLOR)"
	@docker images
	@echo "\n$(GREEN)Docker Containers:$(RESET_COLOR)"
	@docker ps -a
	@echo "\n$(GREEN)Docker Volumes:$(RESET_COLOR)"
	@docker volume ls
	@echo "\n$(GREEN)Docker System Disk Usage:$(RESET_COLOR)"
	@docker system df
	@VLMS="$$(docker volume ls -q)"; \
	if [ ! -z "$$VLMS" ]; then \
		echo "\n$(GREEN)Volumes mountpoints...$(RESET_COLOR)"; \
		docker volume inspect -f '"Mountpoint": "{{ .Mountpoint }}"' $$VLMS; \
	fi

logs:
	@echo "$(GREEN)Showing logs for all containers...$(RESET_COLOR)"
	@cd $(WORKDIR)/srcs && docker compose logs

inspect-vlm:
	@VLMS="$$(docker volume ls -q)"; \
	if [ -z "$$VLMS" ]; then \
		echo "$(RED)No volumes to show...$(RESET_COLOR)"; \
	else \
		echo "$(GREEN)Volumes mountpoints...$(RESET_COLOR)"; \
		docker volume inspect -f '"Mountpoint": "{{ .Mountpoint }}"' $$VLMS; \
	fi

clean-containers:
	@CTRS="$$(docker ps -aq)"; \
	if [ -z "$$CTRS" ]; then \
		echo "\n$(RED)No containers to remove$(RESET_COLOR)"; \
	else \
		echo "\n$(RED)Removing Docker containers...$(RESET_COLOR)"; \
		docker rm -f $$CTRS; \
	fi

clean-imgs:
	@IMGS="$$(docker images -q)"; \
	if [ -z "$$IMGS" ]; then \
		echo "\n$(RED)No images to remove$(RESET_COLOR)"; \
	else \
		echo "\n$(RED)Removing Docker images...$(RESET_COLOR)"; \
		docker rmi -f $$IMGS; \
	fi

clean-volumes:
	@VLMS="$$(docker volume ls -q)"; \
	if [ -z "$$VLMS" ]; then \
		echo "\n$(RED)No volumes to remove$(RESET_COLOR)"; \
	else \
		echo "\n$(RED)Removing Docker volumes...$(RESET_COLOR)"; \
		docker volume rm $$VLMS; \
	fi

clean-cache:
	@echo "$(RED)Removing Docker build cache...$(RESET_COLOR)"
	@docker builder prune -af || true
	@docker buildx prune -af || true

clean: down clean-imgs
	@echo "$(RED)All Docker containers and images removed!$(RESET_COLOR)"

fclean: clean clean-volumes
	@echo "$(RED)Full Docker cleanup done!$(RESET_COLOR)"

full-clean: fclean clean-cache
	@echo "$(RED)Complete Docker cleanup done!$(RESET_COLOR)"

re: fclean build

.PHONY: build all down infos logs clean-containers clean-imgs clean-volumes clean-cache clean fclean re
