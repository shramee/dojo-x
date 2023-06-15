build:
	sozo build

test:
	sozo test

deploy_dojo:
	@SOZO_OUT="$$(sozo migrate)"; echo "$$SOZO_OUT"; \
	WORLD_ADDR="$$(echo "$$SOZO_OUT" | grep "World at address" | rev | cut -d " " -f 1 | rev)"; \
	if [ -z "$$WORLD_ADDR" ] then echo "$$WORLD_ADDR" > ./deployed_worlds;
