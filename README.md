# Summary

This repository is a resty Docker container which offers a website with music
sets. The production version is found at https://hotmixes.net/

# Prerequisists

Install `docker-compose`, e.g. with

    sudo apt-get install docker-compose

# Configuration

For testing, modify `docker-compose-local.yml` to find MP3 files on your local
machine. Alternatively, create a directoru `~/Music/alfa` with subdirectores
holding MP3 files.

# Build and run

The local container is build and run with

    docker-compose -f docker-compose-local.yml up --build

# Access

The website offered by the local container is at http://localhost:8080
