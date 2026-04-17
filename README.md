# Linux Routing Lab with Docker

## Prerequisite
sudo apt-get install docker-compose docker.io

## Quick Start
./scripts/setup.sh

## Reproduce Bug
ping serverA   # OK
ping serverB   # FAIL

## Debug
docker exec serverB ip route get 10.20.17.25

