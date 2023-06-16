account_address="0x06f62894bfd81d2e396ce266b2ad0f21e0668d604e5bb1077337b6d570a54aea"
private_key="0x07230b49615d175307d580c33d6fda61fc7b9aec91df0f5c1a5ebe3b8cbfee02"
katana_url="http://127.0.0.1:5050"

katana:
	katana --chain-id TESTNET

build:
	sozo build

test:
	sozo test

start:
	docker compose up

indexer:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	torii -w $$WORLD_ADDR --rpc $(katana_url)

deploy: deploy_contracts
	@SOZO_OUT="$$(sozo migrate --rpc-url http://localhost:5050)"; echo "$$SOZO_OUT"; \
	WORLD_ADDR="$$(echo "$$SOZO_OUT" | grep "World at address" | rev | cut -d " " -f 1 | rev)"; \
	[ -n "$$WORLD_ADDR" ] && \
		echo "$$WORLD_ADDR" > ../last_deployed_world && \
		echo "$$SOZO_OUT" > ../deployed.log;

deploy_contracts:

	cd dao; \
	@DAO_DEC="$$(protostar declare dao --account-address $(account_address) \ --gateway-url $(katana_url)
		--max-fee auto --private-key-path ../.pkey)";
	echo "$${DAO_DEC}"; echo "$${DAO_DEC}" >> ./deployed.log







	@DAO_DEC="$$(protostar --profile devnet declare universe --account-address $(account_address) \
		--max-fee auto --private-key-path ./.pkey)";
	echo "$${DAO_DEC}"; echo "$${DAO_DEC}" >> ./deployed.log

serve:
	@cd ./client; \
	rustup override set nightly; \
	WORLD_ADDR=$$(tail -n1 ../last_deployed_world) cargo run --release;

deploy_and_run: deploy indexer serve
