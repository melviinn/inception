#Makefile that build all the Dockerfiles in the current directory

WORKDIR := $(shell pwd)
DOCKER_IMGS := $(shell docker images -q)

build:
	cd $(WORKDIR)/srcs && docker compose up --build -d

down:
	cd $(WORKDIR)/srcs && docker compose down

logs:
	cd $(WORKDIR)/srcs && docker compose logs -f

clean-imgs:	
	docker rmi $(DOCKER_IMGS)

fclean: down clean-imgs

.PHONY:
	build down logs
