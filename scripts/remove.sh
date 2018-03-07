#!/bin/bash
docker stop pico
docker rm pico
docker ps -f name=pico
