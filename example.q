/Example Web API application

/load API library
\l api.q

example:{[user;num;fields]
  d:()!();
  d[`user]:string user;
  fields:`$" "vs string fields;
  d[`response]:flip fields!flip c cut (num*c:count fields)?0Wi;
  :d;
 }
.api.define[`example;`user`num`fields!(`username;10;`$"col1 col2 col3")];

gettime:{[] enlist[`time]!enlist .z.P}
.api.define[`gettime;()!()]
