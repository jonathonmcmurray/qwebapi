/Example Web API application

.utl.require"webapi"

example:{[user;num;fields]
  d:()!();
  d[`user]:string user;
  fields:`$" "vs string fields;
  d[`response]:flip fields!flip c cut (num*c:count fields)?0Wi;
  :d;
 }
.api.define[`example;`user`num`fields!(`username;10;`$"col1 col2 col3");`user;`POST];

gettime:{[] enlist[`time]!enlist .z.P}
.api.define[`gettime;()!();();`]

mapval:{[input;dict] dict@input}
.api.define[`mapval;`input`dict!(`;`a`b`c!1 2 3);`input;`]
