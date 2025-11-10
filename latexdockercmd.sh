#!/bin/sh
IMAGE=blang/latex:ubuntu
exec docker run --rm -i --user="$(id -u):$(id -g)" --net=none -v "$PWD":/data "$IMAGE" "$@"

# Typical build sequence looks like this
# pdflatex main.tex && \
# bibtex main && \
# pdflatex main.tex && \
# pdflatex main.tex
