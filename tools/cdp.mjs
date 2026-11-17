// Minimal CDP client for the Sable page on 127.0.0.1:9222.
// Usage: node --experimental-websocket cdp.mjs eval <file.js>
//        node --experimental-websocket cdp.mjs shot <out.png>
import { readFileSync, writeFileSync } from 'node:fs';

const [mode, arg] = process.argv.slice(2);
const list = await (await fetch('http://127.0.0.1:9222/json/list')).json();
const page = list.find((t) => t.type === 'page' && t.url.startsWith('sable-app://'));
const ws = new WebSocket(page.webSocketDebuggerUrl);
let id = 0;
const pending = new Map();
ws.onmessage = (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
};
const send = (method, params = {}) => new Promise((res) => {
  const i = ++id; pending.set(i, res); ws.send(JSON.stringify({ id: i, method, params }));
});
await new Promise((r) => (ws.onopen = r));

if (mode === 'eval') {
  const expr = readFileSync(arg, 'utf8');
  const r = await send('Runtime.evaluate', { expression: expr, awaitPromise: true, returnByValue: true });
  if (r.result?.exceptionDetails) console.error(JSON.stringify(r.result.exceptionDetails, null, 1));
  const v = r.result?.result?.value;
  console.log(typeof v === 'string' ? v : JSON.stringify(v, null, 1));
} else if (mode === 'shot') {
  const r = await send('Page.captureScreenshot', { format: 'png' });
  writeFileSync(arg, Buffer.from(r.result.data, 'base64'));
  console.log('saved', arg);
}
ws.close();
