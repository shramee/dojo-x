/*
  	World endpoints
	---------------
	ex constructor
	ex initialize
	vi is_authorized
	vi is_account_admin
	ex register_component
	vi component
	ex register_system
	vi system
	ex execute
	ex uuid
	ex set_entity
	ex delete_entity
	vi entity
	vi entities
	ex set_executor
	vi executor
	ex assume_role
	ex clear_role
	vi execution_role
	vi system_components
	vi is_system_for_execution
*/
class DojoCalls {
  constructor() {
    let contract =
      '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7';
    // this.rpc = new starknet.RpcProvider({
    //   nodeUrl: ecs_data.rpc || 'localhost:5050',
    // });

    setTimeout(async () => {
      await starknet.enable();
      this.contract = new starknet_.Contract(
        ecs_data.abi,
        contract,
        starknet.provider,
      );
    }, 1000);
  }

  play() {
    this.world.call('executor');
  }

  async raw_fetch(method, params = []) {
    let req = await fetch(ecs_data.rpc || 'http://localhost:5050', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 1,
        method,
        params,
      }),
    });
    return await req.json();
  }

  call() {
    return this.rpc('starknet_call');
  }
}

window.dojo = new DojoCalls();
