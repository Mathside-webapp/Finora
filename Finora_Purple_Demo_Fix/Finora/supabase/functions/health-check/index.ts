// Authenticated health check. No elevated secrets and no service-role access.
import { withSupabase } from 'npm:@supabase/server';
const headers={'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization,apikey,content-type','Access-Control-Allow-Methods':'POST,OPTIONS'};
export default {fetch: withSupabase({auth:'user'}, async (request,ctx)=>{
 if(request.method==='OPTIONS')return new Response(null,{status:204,headers});
 if(request.method!=='POST')return Response.json({error:'Method not allowed'},{status:405,headers});
 const {count,error}=await ctx.supabase.from('finance_records').select('id',{count:'exact',head:true});
 if(error)return Response.json({error:'Unable to access user records'},{status:500,headers});
 return Response.json({ok:true,visibleRecords:count},{headers});
})};
