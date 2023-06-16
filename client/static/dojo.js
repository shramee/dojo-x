class DojoCalls {
  async call(method, params = []) {
    let req = await fetch('http://localhost:5050', {
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
}
