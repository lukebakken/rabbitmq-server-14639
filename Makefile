.PHONY: clean down up perms rmq-perms start-shovel stop-shovel

DOCKER_FRESH ?= false
RABBITMQ_DOCKER_TAG ?= rabbitmq:4-management

clean: perms
	git clean -xffd

down:
	docker compose down

up:
ifeq ($(DOCKER_FRESH),true)
	docker compose build --no-cache --pull --build-arg RABBITMQ_DOCKER_TAG=$(RABBITMQ_DOCKER_TAG)
	docker compose up --pull always
else
	docker compose build --build-arg RABBITMQ_DOCKER_TAG=$(RABBITMQ_DOCKER_TAG)
	docker compose up
endif

perms:
	sudo chown -R "$$(id -u):$$(id -g)" data log

start-shovel:
	docker compose exec rmq rabbitmqctl set_parameter shovel rmq-14639-shovel '{"src-protocol": "amqp091", "src-uri": "amqp://rmq/vhost0", "src-queue": "rmq-14639", "dest-protocol": "amqp091", "dest-uri": "amqp://rmq/vhost1", "dest-exchange": "rmq-14639", "ack-mode": "on-confirm", "src-prefetch-count": 1000, "src-delete-after": "queue-length"}'

stop-shovel:
	docker compose exec rmq rabbitmqctl clear_parameter shovel rmq-14639-shovel
