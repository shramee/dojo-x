build:
	cd ./dojo; sozo build

test:
	cd ./dojo; sozo test

start:
	docker compose up

indexer:
	@WORLD_ADDR=$$(tail -n1 ./deployed_worlds); \
	torii -w $$WORLD_ADDR --rpc http://127.0.0.1:5050

deploy:
	@cd ./dojo; \
	SOZO_OUT="$$(sozo migrate)"; echo "$$SOZO_OUT"; \
	echo "$$SOZO_OUT" | grep "World at address" | rev | cut -d " " -f 1 | rev >> ./deployed_worlds

serve:
	@cd ./client; WORLD_ADDR=$$(tail -n1 ../deployed_worlds) cargo run --release;

deploy_and_run: deploy indexer serve
