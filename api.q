/api.q - a generic framework for building web APIs backed by kdb+
\d .api

urldecode:{(!/)"S=&"0:.h.uh ssr[x;"+";" "]}                                         //decode an urlencoded string into kdb dict
funcs:([func:`$()];defaults:())                                                     //config of funcs
define:{.api.funcs[x;`defaults]:y}                                                  //function to define an API function

xc:{[f;x] /f - function, x - arguments
  /* execute given function with arguments, error trap & return result as JSON */
  :.[{.j.j x . y};(f;x);{.j.j enlist[`error]!enlist x}];                            //error trap, build JSON for fail
 }

.z.ph:{[x] /x - (request;headers)
  f:`$first "?"vs x 0;                                                              //function name
  if[not f in key .api.funcs;:.h.hy[`json] .j.j "Invalid function"];                //error on invalid functions
  a:.Q.def[.api.funcs[f;`defaults]]urldecode last "?"vs x 0;                        //args dict
  p:value[value f][1];                                                              //function params
  :.h.hy[`json] xc[value f;value p#a];                                              //run function & return as JSON
 }
