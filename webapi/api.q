/api.q - a generic framework for building web APIs backed by kdb+
\d .api

funcs:([func:`$()];defaults:();required:();methods:())                              //config of funcs
define:{[f;d;r;m].api.funcs[f]:`defaults`required`methods!(d;(),r;$[`~m;`POST`GET;(),m])} //function to define an API function

ret:$[.z.K>=3.7;{.h.hy[1b;x;-35!(6;y)]};.h.hy];

xc:{[m;f;x] /m- HTTP method,f - function name (sym), x - arguments
  /* execute given function with arguments, error trap & return result as JSON */
  if[not f in key .api.funcs;:.j.j "Invalid function"];                             //error on invalid functions
  if[not m in .api.funcs[f;`methods];:.j.j "Invalid method for this function"];     //error on invalid method
  if[count a:.api.funcs[f;`required] except key x;:.j.j "Missing required param(s): "," "sv string a]; //error on missing required params
  p:value[value f][1];                                                              //function params
  x:.Q.def[.api.funcs[f;`defaults]]x;                                               //default values/types for args
  :.[{.j.j x . y};(value f;value p#x);{.j.j enlist[`error]!enlist x}];              //error trap, build JSON for fail
 }

prs:.req.ty[`json`form]!(.j.k;.url.dec)                                             //parsing functions based on Content-Type
getf:{`$first "?"vs first " "vs x 0}                                                //function name from raw request
spltp:{0 1_'(0,first ss[x 0;" "])cut x 0}                                           //split POST body from params
prms:{.url.dec last "?"vs x 0}                                                      //parse URL params into kdb dict

.z.ph:{[x] /x - (request;headers)
  /* HTTP GET handler */
  :ret[`json] xc[`GET;getf x;prms x];                                               //run function & return as JSON
 }

.z.pp:{[x] /x - (request;headers)
  /* HTTP POST handler */
  b:spltp x;                                                                        //split POST body from params
  x[1]:lower[key x 1]!value x 1;                                                    //lower case keys
  a:prs[x[1]`$"content-type"]b[1];                                                  //parse body depending on Content-Type
  if[99h<>type a;a:()];                                                             //if body doesn't parse to dict, ignore
  a:@[a;where 10<>type each a;string];                                              //string non-strings for .Q.def
  :ret[`json] xc[`POST;getf x;a,prms b];                                            //run function & return as JSON
 }

/ AUTHORIZATION - start with -auth {file.txt} to enable Basic HTTP Auth
/ file.txt format = user:pass on each line

authorize:{
  /* take Authorization header and pass to relevant handler */
  a:x[1]`Authorization;                                                             //extract authorization header
  if[0=count a;:(0;"")];                                                            //deny if no authorization header
  a:@[;0;lower]"S*"$" "vs a;                                                        //split to type & credentials
  if[not a[0] in key verify;:(0;"")];                                               //deny if unsupported auth method
  :verify[a 0]a 1;                                                                  //pass off to relevant verify func
 }

verify.basic:{
  /* handler for basic auth */
  x:.req.b64decode x;                                                               //base 64 decode credentials
  u:first s:":"vs x;p:last s;                                                       //split username & password
  if[(x in auth`plaintext)|(u,":",raze string md5 p)in auth`md5;                    //check plaintext & md5 password
     :(1;u);                                                                        //authorize
    ];
  :(0;"");                                                                          //deny access if not in authed users
 }

readauth:{
  /* read authorisation file & split into md5 and plaintext */
  a:read0 x;                                                                        //read file
  p:last each":"vs'a;                                                               //get passwords
  h:raze .Q.n,6#'.Q`a`A;                                                            //hexadecimal chars
  m:a where c:(32=count each p)&all each p in\:h;                                   //get all md5 passwords (32 digit hex nums)
  p:a where not c;                                                                  //plaintext passwords
  :`md5`plaintext!(m;p);                                                            //return dict
 }

if[`auth in key o:.Q.opt .z.x;
   auth:readauth first hsym `$o`auth;                                               //load authorized user:pass combos
   .z.ac:authorize;                                                                 //set authorization handler
  ];
