cleanup:
	set -x
	docker rm -v $$(docker ps -q -a --no-trunc) || exit 0
	docker rmi $$(docker images --no-trunc | grep none | awk '{print $$3 }') || exit 0

build:
	./build.sh

install:
	./install.sh

start:
	./start.sh
