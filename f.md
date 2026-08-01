docker-compose -f docker/docker-compose.yml build

docker-compose -f docker/docker-compose.yml up -d

docker-compose -f docker/docker-compose.yml exec dev-env bash
COMPOSE_BAKE=false docker-compose -f docker/docker-compose.yml build --no-cache