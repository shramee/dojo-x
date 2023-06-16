build:
	cd ./autonomous-agents; sozo build

test:
	cd ./autonomous-agents; sozo test

start:
	docker compose up

indexer:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	torii -w $$WORLD_ADDR --rpc http://127.0.0.1:5050

deploy:
	@cd ./autonomous-agents; \
	SOZO_OUT="$$(sozo migrate --rpc-url http://localhost:5050)"; echo "$$SOZO_OUT"; \
	WORLD_ADDR="$$(echo "$$SOZO_OUT" | grep "World at address" | rev | cut -d " " -f 1 | rev)"; \
	[ -n "$$WORLD_ADDR" ] && \
		echo "$$WORLD_ADDR" > ../last_deployed_world && \
		echo "$$SOZO_OUT" > ../deployed.log;

serve:
	@cd ./client; \
	rustup override set nightly; \
	WORLD_ADDR=$$(tail -n1 ../last_deployed_world) cargo run --release;

deploy_and_run: deploy indexer serve
