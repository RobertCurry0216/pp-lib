include ./../../.env

NAME := basic_platformer
DEST := ./builds/$(NAME).pdx
SOURCE := .


all: build run

build:
	pdc $(SOURCE) $(DEST)

run:
	$(RUN_SIMULATOR) $(DEST)

.PHONY: run build