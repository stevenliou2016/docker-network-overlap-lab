# Linux Routing Lab with Docker

## Quick Start
./scripts/setup.sh

## Reproduce Bug
ping serverA   # OK
ping serverB   # FAIL

## Debug
docker exec serverB ip route get 10.20.17.25

