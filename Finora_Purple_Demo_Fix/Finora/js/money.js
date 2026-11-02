export function cents(value){const s=String(value??'0').trim();if(!/^-?\d+(\.\d{1,2})?$/.test(s))throw Error('Use a valid amount with at most two decimals');const neg=s[0]==='-';const [whole,fraction='']=s.replace('-','').split('.');return (neg?-1:1)*(Number(whole)*100+Number(fraction.padEnd(2,'0')))}
export function decimal(c){return (c/100).toFixed(2)}
export function money(c,code='PHP'){return new Intl.NumberFormat('en-PH',{style:'currency',currency:code}).format(c/100)}
export function sum(rows,fn){return rows.reduce((n,r)=>n+fn(r),0)}
export function uid(){return crypto.randomUUID()}
export function today(){return new Date().toLocaleDateString('en-CA',{timeZone:'Asia/Manila'})}
export function month(){return today().slice(0,7)}
export function safe(s){return String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
export function csvSafe(v){const s=String(v??'');return '"'+(/^[\s]*[=+@\-\t\r]/.test(s)?"'"+s:s).replaceAll('"','""')+'"'}
export function outstanding(loan,payments){return Math.max(0,loan.amount_cents-sum(payments.filter(p=>p.parent_id===loan.id),p=>p.principal_cents||0))}
