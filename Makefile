SHELL := /bin/bash
IMAGE_VERSION=0.0.19
IMAGE_NAME="vakaras/viper-build:${IMAGE_VERSION}"
USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)

shell: | workspace
	sudo docker run --rm -ti \
		-u ${USER_ID}:${GROUP_ID} \
		-v "${CURDIR}/..:/data" \
		${IMAGE_NAME} /bin/bash

root_shell:
	sudo docker run --rm -ti \
		${IMAGE_NAME} /bin/bash

workspace:
	mkdir -p workspace

publish:
	sudo docker push ${IMAGE_NAME}
