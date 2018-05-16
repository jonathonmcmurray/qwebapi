# qwebapi

A simple framework/library for creating a web API powered by kdb+/q. Provided
with a trivial example API application (see `example.q`)

## Usage

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

## Roadmap

Things that need to be done:

- [X] Handle POST requests (inc. JSON body)
- [ ] Required & optional parameters
- [ ] Example with TorQ integration? (FSP fork)
- [X] Replace urlencode definition with reQ (?)
- [X] Error handling of function execution
- [X] Generalise `.z.pp` and `.z.ph` - refactor shared code into other functions
- [ ] Support for authentication (?)