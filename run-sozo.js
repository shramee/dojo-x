var { spawn } = require("child_process");

function run() {
    let ls = spawn(
        "sozo execute Update --world 0x7f1d6c1b15e03673062d8356dc1174d5d85c310479ec49fe781e8bf89e4c4f8 " +
            "--account-address 0x06f62894bfd81d2e396ce266b2ad0f21e0668d604e5bb1077337b6d570a54aea " +
            "--private-key 0x07230b49615d175307d580c33d6fda61fc7b9aec91df0f5c1a5ebe3b8cbfee02 " +
            "--rpc-url http://localhost:5050/ "
    );
    ls.stdout.on("data", (data) => {
        console.log(`stdout: ${data}`);
    });

    ls.stderr.on("data", (data) => {
        console.error(`stderr: ${data}`);
    });
    ls.on("error", (e) => console.log(e));
}
run();
// setInterval(run, 100);
