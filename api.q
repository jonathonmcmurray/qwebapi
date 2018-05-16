/api.q - a generic framework for building web APIs backed by kdb+
\d .api

/load reQ library for HTTP related functions
\l reQ/req.q

funcs:([func:`$()];defaults:())                                                     //config of funcs
define:{.api.funcs[x;`defaults]:y}                                                  //function to define an API function

xc:{[f;x] /f - function, x - arguments
  /* execute given function with arguments, error trap & return result as JSON */
  :.[{.j.j x . y};(f;x);{.j.j enlist[`error]!enlist x}];                            //error trap, build JSON for fail
 }

prs:.req.ty[`json`form]!(.j.k;.req.urldecode)                                       //parsing functions based on Content-Type
getf:{`$first "?"vs first " "vs x 0}                                                //function name from raw request
spltp:{0 1_'(0,first ss[x 0;" "])cut x 0}                                           //split POST body from params

.z.ph:{[x] /x - (request;headers)
  /* HTTP GET handler */
  f:getf x;                                                                         //get function name
  if[not f in key .api.funcs;:.h.hy[`json] .j.j "Invalid function"];                //error on invalid functions
  a:.Q.def[.api.funcs[f;`defaults]].req.urldecode last "?"vs x 0;                   //args dict
  p:value[value f][1];                                                              //function params
  :.h.hy[`json] xc[value f;value p#a];                                              //run function & return as JSON
 }

.z.pp:{[x] /x - (request;headers)
  /* HTTP POST handler */
  f:getf x;                                                                         //get function name
  if[not f in key .api.funcs;:.h.hy[`json] .j.j "Invalid function"];                //error on invalid functions
  b:spltp x;                                                                        //split POST body from params
  a:prs[x[1]`$"Content-Type"]b[1];                                                  //parse body depending on Content-Type
  a:@[a;where 10<>type each a;string];                                              //string non-strings for .Q.def
  a:.Q.def[.api.funcs[f;`defaults]]a,.req.urldecode last "?"vs b 0;                 //args dict
  p:value[value f][1];                                                              //function params
  :.h.hy[`json] xc[value f;value p#a];                                              //run function & return as JSON
 }