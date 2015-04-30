install:
	./install.sh

cleanup:
	docker rm -v $$(docker ps -a -q | grep -v $$(docker ps -q | xargs | sed 's/ /\\\|/')) 2>/dev/null
	docker rmi $$(docker images --no-trunc | grep none | awk '{print $$3 }') 2>/dev/null

build:
	./build.sh

start:
	./start.sh

.PHONY: install cleanup build start
