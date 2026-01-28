#Makefile that build all the Dockerfiles in the current directory

WORKDIR := $(shell pwd)

build:
	cd $(WORKDIR)/srcs && docker compose up --build -d

down:
	cd $(WORKDIR)/srcs && docker compose down

logs:
	cd $(WORKDIR)/srcs && docker compose logs -f

.PHONY:
	build down logs
