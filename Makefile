.PHONY: build

default: permissions setup build

permissions:
	chmod +x setup.sh
	chmod +x build.sh

setup:
	./setup.sh

build:
	./build.sh