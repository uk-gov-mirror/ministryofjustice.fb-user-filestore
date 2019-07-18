dev:
	echo "TODO: Remove dev function call from deploy-utils"

test:
	echo "TODO: Remove test function call from deploy-utils"

integration:
	echo "TODO: Remove integration function call from deploy-utils"

live:
	echo "TODO: Remove live function call from deploy-utils"

build: stop
	docker-compose build --build-arg BUNDLE_FLAGS=''

serve: build
	docker-compose up -d app

stop:
	docker-compose down -v

spec: build
	docker-compose run --rm app bundle exec rspec

init:
	$(eval export ECR_REPO_URL=754256621582.dkr.ecr.eu-west-2.amazonaws.com/formbuilder/fb-user-filestore-api)

install_build_dependencies:
	pip install --user awscli
	$(eval export PATH=${PATH}:${HOME}/.local/bin/)

build_and_push: install_build_dependencies init
	@eval $(shell aws ecr get-login --no-include-email --region eu-west-2)
	docker build --build-arg BUNDLE_FLAGS="--without test development" -t ${ECR_REPO_URL}:latest -t ${ECR_REPO_URL}:${CIRCLE_SHA1} -f ./Dockerfile .
	docker push ${ECR_REPO_URL}:latest
	docker push ${ECR_REPO_URL}:${CIRCLE_SHA1}

.PHONY := build_and_push serve spec install_build_dependencies dev test live integration
