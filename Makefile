CONTAINER_NAME := jenkins-server-container

install:
	./scripts/install.sh

clean:
	docker rm -v $$(docker ps -a -q | grep -v "$$(docker ps -q | xargs | sed 's/ /\\\|/g') ") 2>/dev/null || echo Nothing to do
	docker rmi $$(docker images --no-trunc | grep none | awk '{print $$3 }') 2>/dev/null || echo Nothing to do

build:
	./scripts/build.sh

start:
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p 8080:8080 \
		-v /var/jenkins_home:/var/jenkins_home \
		--restart always \
		jenkins_server

stop:
	@echo 'Stopping $(CONTAINER_NAME)'
	docker stop $(CONTAINER_NAME)

rebuild: build stop clean start


.PHONY: install clean build start stop rebuild
