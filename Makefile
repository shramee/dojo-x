ACCOUNT=0x0390595E0f30299328F610C689fcFf5B0ee48eE971f0742b5568e5Dd1DE6e324
NODE_URL=https://starknet-goerli.g.alchemy.com/v2/VjT7v9HByuw3CZy91SrPSl6lbaYJxP6Y/

build:
	cd ./autonomous-agents; sozo build

test:
	cd ./autonomous-agents; sozo test

start:
	docker compose up

indexer:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	torii -w $$WORLD_ADDR --rpc $(NODE_URL)

deploy:
	@echo Starting deployment... > last_deployment;
	cd dao; DEPLOYMENT_LOG="$$(protostar declare dao --network testnet --account-address $(ACCOUNT) --network testnet \
		--private-key-path ../.private_key --max-fee 99999999999)"; echo "$$DEPLOYMENT_LOG"; \
	# [ -n "$$DEPLOYMENT_LOG" ] && echo "$$DEPLOYMENT_LOG" >> ./last_deployment;

	cd universe; DEPLOYMENT_LOG="$$(protostar declare universe --network testnet --account-address $(ACCOUNT) --network testnet \
		--private-key-path ../.private_key --max-fee 99999999999)"; echo "$$DEPLOYMENT_LOG"; \
	# [ -n "$$DEPLOYMENT_LOG" ] && echo "$$DEPLOYMENT_LOG" >> ./last_deployment;

serve:
	@cd ./client; \
	rustup override set nightly; \
	WORLD_ADDR=$$(tail -n1 ../last_deployed_world) cargo run --release;

deploy_and_run: deploy indexer serve
