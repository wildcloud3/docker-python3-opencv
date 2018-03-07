#!/bin/bash
docker run -dt --name pico wildcloud3/py3cv-tess
docker ps -f name=pico
