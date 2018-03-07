#!/bin/bash
docker run -dt --name pico wildcloud/docker-python3-opencv
docker ps -f name=pico
