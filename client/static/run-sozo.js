var { spawn } = require('child_process');
setInterval(function () {
    let s = spawn('sozo execute update');
    s.on('error', e => console.log(e));
}, 100);