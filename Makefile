#Makefile that build all the Dockerfiles in the current directory

WORKDIR := $(shell pwd)

all: build

build:
	cd $(WORKDIR)/srcs/requirements/nginx && docker build -t nginx . && cd $(WORKDIR)
	cd $(WORKDIR)/srcs/requirements/mariadb && docker build -t mariadb . && cd $(WORKDIR)
	cd $(WORKDIR)/srcs/requirements/wordpress && docker build -t wordpress . && cd $(WORKDIR)

