import {encrypt,decrypt} from './crypto.js';
let db,pin,user;export async function openVault(userId,pass){user=userId;pin=pass;db=await new Promise((resolve,reject)=>{const r=indexedDB.open('finora-vault-v1',1);r.onupgradeneeded=()=>r.result.createObjectStore('vault');r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error)});const stored=await read();if(stored){await decrypt(stored,pin)}else await write(await encrypt({records:[],queue:[]},pin))}
function read(){return new Promise((resolve,reject)=>{const r=db.transaction('vault').objectStore('vault').get(user);r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error)})}
function write(value){return new Promise((resolve,reject)=>{const r=db.transaction('vault','readwrite').objectStore('vault').put(value,user);r.onsuccess=()=>resolve();r.onerror=()=>reject(r.error)})}
export async function load(){return decrypt(await read(),pin)}
export async function save(state){await write(await encrypt(state,pin))}
export function lock(){pin=null;user=null;db?.close();db=null}
