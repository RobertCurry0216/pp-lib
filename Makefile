include .env

SOURCE_1 := ./source

build:
	$(PYTHON) ./build.py

.PHONY: build