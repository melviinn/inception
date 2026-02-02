#Makefile that build all the Dockerfiles in the current directory

WORKDIR		:= $(shell pwd)
DOCKER_IMGS	:= $(shell docker images -q)
DOCKER_CTRS	:= $(shell docker ps -aq)
DOCKER_VLMS	:= $(shell docker volume ls -q)

# Colors
RED			:=	$(shell tput -Txterm setaf 1)
GREEN		:=	$(shell tput -Txterm setaf 2)
RESET_COLOR	:=	$(shell tput -Txterm sgr0)

build:
	@cd $(WORKDIR)/srcs && docker compose up --build -d
	@echo "\n$(GREEN)Successfully built and started all Docker images and containers! ✅$(RESET_COLOR)"

down:
	@cd $(WORKDIR)/srcs && docker compose down

clean-containers:
	@if [ -z "$(DOCKER_CTRS)" ]; then \
		echo "\n$(RED)No containers to remove$(RESET_COLOR)"; \
	else \
		echo "\n$(RED)Removing Docker containers...$(RESET_COLOR)"; \
		docker rm -f $(DOCKER_CTRS); \
	fi

clean-imgs:
	@if [ -z "$(DOCKER_IMGS)" ]; then \
		echo "\n$(RED)No images to remove$(RESET_COLOR)"; \
	else \
		docker rmi --force $(DOCKER_IMGS); \
	fi

clean-volumes:
	@if [ -z "$(DOCKER_VLMS)" ]; then \
		echo "\n$(RED)No volumes to remove$(RESET_COLOR)"; \
	else \
		echo "\n$(RED)Removing Docker volumes...$(RESET_COLOR)"; \
		docker volume rm $(DOCKER_VLMS); \
	fi

fclean: down clean-containers clean-imgs clean-volumes
	@echo "\n$(RED)All Docker containers, images and volumes has been removed!$(RESET_COLOR)"


re: fclean build

.PHONY: build down clean-containers clean-imgs fclean re
