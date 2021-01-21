# External Authz PoC

This is a PoC around a generic Authorization Server based on Open Policy Agent and the extAuthz HTTP envoy protocol.

The OPA plugin implementation can be found at: https://github.com/jmprusi/opa-http-extauthz

## TODO

- [ ] Openresty Implementation: If authorization service is down, add the option to deny or allow the request. 
- [ ] Openresty Implementation: Allow to pass a selected list of headers (user-configurable).
- [ ] Openresty Implementation: Allow to pass the body of the original request (user-configurable).

## Getting started

This repository consist of:

```
.
├── Makefile
├── README.md
├── envoy
│   ├── envoy-config.yaml   <-------- Envoy Configuration with extAuthz HTTP enabled.
│   └── envoy.yaml          <-------- Envoy Kubernetes deployment.
├── httpbin
│   └── httpbin.yaml        <-------- HTTPBin Kubernetes deployment, a simple service for testing http calls.
├── opa
│   ├── authz.rego          <-------- OpenPolicyAgent rego policy.
│   ├── opa.config          <-------- OpenPolicyAgent config to enable Envoy HTTP ExtAuthz plugin.
│   └── opa.yaml            <-------- OpenPolicyAgent kubernetes deployment.
├── openresty
│   ├── Dockerfile          <-------- Required Openresty Docker image with Lua-resty-http module installed.
│   ├── example-authz.conf  <-------- Example Openresty implementation of Envoy HTTP ExtAuthz.
│   └── openresty.yaml      <-------- Openresty Kubernetes deployment.
└── scripts
    └── local-setup.sh      <-------- Environment setup scripts (Creates a Kind cluster and deploys components) 
```

## Setup the environment:

`make local-setup` 


## Expose the desired service, for example:

* Envoy:
`kubectl port-forward --namespace extauthz deployment/envoy 8080:8080`

* Openresty: 
`kubectl port-forward --namespace extauthz deployment/openresty 8080:8080`

## Test that the authorization works.

```bash
curl -v localhost:8080/valid
```

## Clean the environment

```bash
kind delete cluster extauthz-poc
```
