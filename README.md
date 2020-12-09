# External Authz PoC

This is a PoC around a generic Authorization Server based on Open Policy Agent and the extAuthz HTTP envoy protocol.

The OPA plugin implementation can be found at: https://github.com/jmprusi/opa-http-extauthz

## TODO

- [ ] Add HTTP extAuthz support to Haproxy, so it can authorize with the OPA server.
- [ ] Use a nicer helloworld service with better logging.
- [ ] Openresty Implementation: If authorization service is down, add the option to deny or allow the request. 
- [ ] Openresty Implementation: Allow to pass a selected list of headers (user-configurable).
- [ ] Openresty Implementation: Allow to pass the body of the original request (user-configurable).

## Getting started

This repository consist of:

```
.
├── docker-compose.yml # Docker-compose to setup this environment easily
├── envoy
│   ├── Dockerfile
│   └── envoy.yaml # Basic envoy config that proxies to helloworld if OPA authorizes it.
├── helloworld
│   ├── Dockerfile
│   └── main.go  # HTTP Hello world
├── opa
│   ├── authz.rego # Default rego policy for authorizing traffic
│   └── opa.config # Default config that enables the envoy extAuthz HTTP plugin
└── openresty
    ├── Dockerfile 
    └── conf
        └── example-authz.conf # Basic config that implements a extAuthz check against OPA
```

Docker-compose will start those services:

- Openresty: Listening on port 8080.
- Envoy: Listening on port 8081.
- OpenPolicyAgent: Listening on port 9292.
- Helloworld: Listening on port 1234.

The default configuration allows only traffic to:

- path: /valid/*
- method: GET

This validation is handled by the OpenPolicyAgent rego policy:

```rego
package envoy.authz

import input.attributes.request.http as http_request

default allow = false

allow {
    action_allowed
}

action_allowed {
  http_request.method == "GET"
  glob.match("/valid/*", [], http_request.path)
}
```

## Starting the environment

You will need docker-compose, and any container runtime compatible running:

```bash
docker-compose build && docker-compose up
```

## Testing the environment

Running CURL against the different HTTP Server should give back the same response:

### Openresty

A valid request: `curl -v ocalhost:8080/valid/abc`

```bash
❯ curl -v localhost:8080/valid/abc
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET /valid/abc HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.64.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Server: openresty/1.19.3.1
< Date: Wed, 09 Dec 2020 21:40:10 GMT
< Content-Type: text/plain; charset=utf-8
< Content-Length: 17
< Connection: keep-alive
<
* Connection #0 to host localhost left intact
Hello, valid/abc!* Closing connection 0
```

Invalid request: `curl -v localhost:8080/whatever`

```bash
❯ curl -v localhost:8080/whatever
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET /whatever HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.64.1
> Accept: */*
>
< HTTP/1.1 403 Forbidden
< Server: openresty/1.19.3.1
< Date: Wed, 09 Dec 2020 21:43:29 GMT
< Content-Type: text/html
< Content-Length: 159
< Connection: keep-alive
<
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>openresty/1.19.3.1</center>
</body>
</html>
* Connection #0 to host localhost left intact
* Closing connection 0
```


### Envoy

A valid request: `curl -v ocalhost:8081/valid/abc`

```
❯ curl -v localhost:8081/valid/abc
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8081 (#0)
> GET /valid/abc HTTP/1.1
> Host: localhost:8081
> User-Agent: curl/7.64.1
> Accept: */*
>
< HTTP/1.1 200 OK
< date: Wed, 09 Dec 2020 21:40:39 GMT
< content-length: 17
< content-type: text/plain; charset=utf-8
< x-envoy-upstream-service-time: 0
< server: envoy
<
* Connection #0 to host localhost left intact
Hello, valid/abc!* Closing connection 0
```

Invalid request: `curl -v localhost:8081/whatever`

```bash
❯ curl -v localhost:8081/whatever
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8081 (#0)
> GET /whatever HTTP/1.1
> Host: localhost:8081
> User-Agent: curl/7.64.1
> Accept: */*
>
< HTTP/1.1 403 Forbidden
< date: Wed, 09 Dec 2020 21:42:48 GMT
< x-envoy-upstream-service-time: 0
< server: envoy
< content-length: 0
<
* Connection #0 to host localhost left intact
* Closing connection 0
```

## Taking down the environment

You can tear down the environment and remove the container by running:
`docker-compose down`
