/api.q - a generic framework for building web APIs backed by kdb+
\d .api

/load reQ library for HTTP related functions
\l reQ/req.q

funcs:([func:`$()];defaults:();required:();methods:())                              //config of funcs
define:{[f;d;r;m].api.funcs[f]:`defaults`required`methods!(d;(),r;$[`~m;`POST`GET;(),m])} //function to define an API function

xc:{[m;f;x] /m- HTTP method,f - function name (sym), x - arguments
  /* execute given function with arguments, error trap & return result as JSON */
  if[not f in key .api.funcs;:.j.j "Invalid function"];                             //error on invalid functions
  if[not m in .api.funcs[f;`methods];:.j.j "Invalid method for this function"];     //error on invalid method
  if[count a:.api.funcs[f;`required] except key x;:.j.j "Missing required param(s): "," "sv string a]; //error on missing required params
  p:value[value f][1];                                                              //function params
  x:.Q.def[.api.funcs[f;`defaults]]x;                                               //default values/types for args
  :.[{.j.j x . y};(value f;value p#x);{.j.j enlist[`error]!enlist x}];              //error trap, build JSON for fail
 }

prs:.req.ty[`json`form]!(.j.k;.req.urldecode)                                       //parsing functions based on Content-Type
getf:{`$first "?"vs first " "vs x 0}                                                //function name from raw request
spltp:{0 1_'(0,first ss[x 0;" "])cut x 0}                                           //split POST body from params
prms:{.req.urldecode last "?"vs x 0}                                                //parse URL params into kdb dict

.z.ph:{[x] /x - (request;headers)
  /* HTTP GET handler */
  :.h.hy[`json] xc[`GET;getf x;prms x];                                             //run function & return as JSON
 }

.z.pp:{[x] /x - (request;headers)
  /* HTTP POST handler */
  b:spltp x;                                                                        //split POST body from params
  a:prs[x[1]`$"Content-Type"]b[1];                                                  //parse body depending on Content-Type
  if[99h<>type a;a:()];                                                             //if body doesn't parse to dict, ignore
  a:@[a;where 10<>type each a;string];                                              //string non-strings for .Q.def
  :.h.hy[`json] xc[`POST;getf x;a,prms b];                                          //run function & return as JSON
 }

/ AUTHORIZATION - start with -auth {file.txt} to enable Basic HTTP Auth
/ file.txt format = user:pass on each line

if[`auth in key o:.Q.opt .z.x;
   auth:read0 first hsym `$o`auth;                                                  //load authorized user:pass combos
   .z.ac:{                                                                          //set .z.ac to check auth
     a:6_x[1]`Authorization;                                                        //drop "Basic " - only basic HTTP auth supported
     if[0=count a;:(0;"")];                                                         //if no user:pass given, deny access
     if[(u:.req.b64decode a) in auth;                                               //decode user:pass, check if authorized
        :(1;first ":" vs u);                                                        //authorize, get username
       ];
     :(0;"");                                                                       //if not authorized, deny access
   }
  ];
