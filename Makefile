#Makefile that build all the Dockerfiles in the current directory

WORKDIR		:= $(shell pwd)
DOCKER_IMGS	:= $(shell docker images -q)

# Colors
RED			:=	$(shell tput -Txterm setaf 1)
GREEN		:=	$(shell tput -Txterm setaf 2)
RESET_COLOR	:=	$(shell tput -Txterm sgr0)

build:
	@cd $(WORKDIR)/srcs && docker compose up --build -d
	@echo "\n$(GREEN)Successfully built and started all Docker images and containers! ✅$(RESET_COLOR)"

down:
	@cd $(WORKDIR)/srcs && docker compose down

clean-imgs:
	@if [ -z "$(DOCKER_IMGS)" ]; then \
		echo "\n$(RED)No images to remove$(RESET_COLOR)"; \
	else \
		docker rmi $(DOCKER_IMGS); \
	fi

fclean: down clean-imgs
	@echo "\n$(RED)All Docker images removed and containers stopped!$(RESET_COLOR)"

re: fclean build

.PHONY:
	build down clean-imgs fclean re
