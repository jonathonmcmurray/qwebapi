/api.q - a generic framework for building web APIs backed by kdb+
\d .api

/load reQ library for HTTP related functions
\l reQ/req.q

funcs:([func:`$()];defaults:())                                                     //config of funcs
define:{.api.funcs[x;`defaults]:y}                                                  //function to define an API function

xc:{[f;x] /f - function name (sym), x - arguments
  /* execute given function with arguments, error trap & return result as JSON */
  if[not f in key .api.funcs;:.j.j "Invalid function"];                             //error on invalid functions
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
  :.h.hy[`json] xc[getf x;prms x];                                                  //run function & return as JSON
 }

.z.pp:{[x] /x - (request;headers)
  /* HTTP POST handler */
  b:spltp x;                                                                        //split POST body from params
  a:prs[x[1]`$"Content-Type"]b[1];                                                  //parse body depending on Content-Type
  if[99h<>type a;a:()];                                                             //if body doesn't parse to dict, ignore
  a:@[a;where 10<>type each a;string];                                              //string non-strings for .Q.def
  :.h.hy[`json] xc[getf x;a,prms b];                                                //run function & return as JSON
 }