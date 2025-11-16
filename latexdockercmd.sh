#!/bin/sh

IMAGE=blang/latex:ubuntu

docker pull "docker.io/$IMAGE"

docker ps | grep "$IMAGE" ||
    docker run --rm -i --detach --name latex-compiler --user="$(id -u):$(id -g)" --net=none -v "$PWD":/data "$IMAGE" "$@"

docker exec -it latex-compiler bash

# Typical build sequence looks like this
# pdflatex main.tex && \
# bibtex main && \
# pdflatex main.tex && \
# pdflatex main.tex
