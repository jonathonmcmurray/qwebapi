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
jonny@grizzly ~ $ wget -O - -q http://localhost:8104/example?user=jonny&num=3
{"user":"jonny","response":[{"col1":56701412,"col2":2125076200,"col3":1574348340},
 {"col1":607727242,"col2":1753511110,"col3":2059906728},
 {"col1":1321772178,"col2":1568639384,"col3":1971895475},
 {"col1":1770327994,"col2":571406836,"col3":323278993},
 {"col1":38705142,"col2":621935707,"col3":1162274860},
 {"col1":1587469071,"col2":504811124,"col3":1818654826},
 {"col1":1724831188,"col2":265874258,"col3":966144090},
 {"col1":1336604866,"col2":896194023,"col3":2107590274},
 {"col1":341364576,"col2":1730748765,"col3":863966213},
 {"col1":293447866,"col2":424844191,"col3":209668615}]}
```

## Roadmap

Things that need to be done:

- [ ] Handle POST requests
- [ ] Required & optional parameters
- [ ] Example with TorQ integration? (FSP fork)
- [ ] Replace urlencode definition with reQ (?)
