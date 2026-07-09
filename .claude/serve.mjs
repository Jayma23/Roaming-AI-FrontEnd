import http from 'node:http';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
// Repo root = parent of this .claude/ dir, resolved relative to the file
// so it keeps working if the folder is moved or renamed.
const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const types = {'.html':'text/html','.css':'text/css','.js':'text/javascript','.svg':'image/svg+xml','.png':'image/png','.json':'application/json'};
http.createServer(async (req,res)=>{
  let p = decodeURIComponent(req.url.split('?')[0]);
  if(p==='/'||p==='') p='/index.html';
  try{
    const buf = await readFile(ROOT+p);
    const ext = p.slice(p.lastIndexOf('.'));
    res.writeHead(200,{'content-type':types[ext]||'application/octet-stream'});
    res.end(buf);
  }catch(e){ res.writeHead(404); res.end('not found'); }
}).listen(4599, ()=>console.log('serving on 4599'));
