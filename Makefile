install:
	./install.sh

cleanup:
	docker rm -v $$(docker ps -a -q | grep -v $$(docker ps -q | xargs | sed 's/ /\\\|/g')) 2>/dev/null || echo Nothing to do
	docker rmi $$(docker images --no-trunc | grep none | awk '{print $$3 }') 2>/dev/null || echo Nothing to do

build:
	./build.sh

start:
	./start.sh

.PHONY: install cleanup build start
