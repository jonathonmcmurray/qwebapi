# qwebapi

[![Anaconda-Server Badge](https://anaconda.org/jmcmurray/webapi/badges/version.svg)](https://anaconda.org/jmcmurray/webapi)
[![Anaconda-Server Badge](https://anaconda.org/jmcmurray/webapi/badges/downloads.svg)](https://anaconda.org/jmcmurray/webapi)

A simple framework/library for creating a web API powered by kdb+/q. Provided
with a trivial example API application (see `example.q`)

Read the blog post: https://jonathonmcmurray.github.io/kdb/q/rest/api/2018/05/22/rest-api-in-kdb.html

## Usage

The library is developed with [qutil](https://github.com/nugend/qutil) in mind.
To use with qutil, install package to location of `QPATH` env var & within q
call

```q
.utl.require"webapi"
```

For simplest installation, install via conda (from Anaconda/Miniconda
installation) e.g.

```
$ conda install -c jmcmurray qwebapi
```

This will ensure all dependencies (incl. `qutil`) are installed.

To use _without_ qutil, download this repo & [reQ](https://github.com/jonathonmcmurray/reQ)
and load `req.q` first followed by `webapi/api.q` from this repo.

Usage of the library is fairly simple. Create a standard q function as usual,
and then use `.api.define` to add it to the public API, while defining
defaults (and therefore datatypes). Examples are seen in `example.q`

## Example

Loading the `example.q` script and setting a port will create an instance of
the example API:

```
jonny@grizzly ~ $ q example.q -p 8104
KDB+ 3.5 2017.10.11 Copyright (C) 1993-2017 Kx Systems
l32/ 2()core 1945MB jonny grizzly 127.0.1.1 NONEXPIRE

q)
```

This example can be accessed via browser, wget, another q session etc.

```
jonny@grizzly ~ $ wget -O - -q http://localhost:8104/gettime
{"time":"2018-05-08D21:36:32.125999000"}
jonny@grizzly ~ $ wget -O - -q 'http://localhost:8104/example?user=jonny&num=3'
{"user":"jonny","response":[{"col1":56701412,"col2":2125076200,"col3":1574348340},
 {"col1":607727242,"col2":1753511110,"col3":2059906728},
 {"col1":293447866,"col2":424844191,"col3":209668615}]}
```

## Authorization

There is inbuilt support for HTTP basic authorization, making use of an
authorization file similar to kdb+ itself uses with the `-u`/`-U` flag. This
file contains pairs of `user:pass` on each line, where `pass` can be plaintext
or the md5 hash of the password. For example, using the following file:

```
$ more auth.txt
user:5f4dcc3b5aa765d61d8327deb882cf99
anon:example
```

It is possible to login with `user:password` or `anon:example`:

```
q).Q.hg`$":http://user:notpassword@localhost:1234/gettime"  //failed login example
""
q).Q.hg`$":http://user:password@localhost:1234/gettime"
"{\"time\":\"2018-05-23D13:16:26.227135000\"}"
q).Q.hg`$":http://anon:example@localhost:1234/gettime"
"{\"time\":\"2018-05-23D13:16:30.522253000\"}"
```

Note that this does enforce one limitation on passwords; they cannot be 32
digit hexdecimal numbers, as these would be indistinguishable from an md5 hash
and therefore would allow logging in using md5 hash, thus defeating the point
of not storing passwords in plaintext.

Adding support for other types of HTTP authentication is simply a case of
adding a `.api.verify.{type}` function where `{type}` is the authentication
type to be added. For example, Basic authentication is handled by
`.api.verify.basic`. Credentials will automatically be passed to the relevant
function based on the type in the request Authorization HTTP header.

## Roadmap

Things that need to be done:

- [X] Handle POST requests (inc. JSON body)
- [X] Required & optional parameters
- [X] Replace urlencode definition with reQ (?)
- [X] Error handling of function execution
- [X] Generalise `.z.pp` and `.z.ph` - refactor shared code into other functions
- [X] Support for authentication (?)
- [ ] Proper documentation

