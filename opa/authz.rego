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
