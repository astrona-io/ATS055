# Summary

Layer 3 and 4 flows show the connection but not the request. To see an HTTP request, Cilium must read the HTTP protocol, and the component that does this is the Envoy proxy that runs inside the Cilium agent.

## What you learned

A layer 7 flow comes from the proxy, and a layer 4 flow comes from the eBPF programs in the kernel. The kernel programs redirect the traffic of an endpoint to the proxy only when a policy with a layer 7 rule selects that endpoint and port. Visibility and enforcement are therefore one feature: the rule that shows the requests also decides which requests are allowed.

An HTTP rule lists allowed request shapes under the port of an ingress or egress rule. Each entry can match the method, the path, the host and headers. Method and path are regular expressions, and the path must match completely. A request that matches no entry is rejected by the proxy with the status 403, and Hubble records an HTTP request flow with the verdict dropped. A source that the policy does not allow at layer 4 is dropped by the kernel programs before the proxy sees it, and its flow has no HTTP fields.

The proxy costs processing and latency, and it cannot read encrypted traffic. HTTPS traffic stays visible only at layer 3 and 4 unless the proxy terminates the encryption. A rule that is too narrow breaks working clients, so you observe the real requests before you restrict them.

## Key facts

- The flow type `L7` comes from Envoy; the type `L3_L4` comes from the kernel programs.
- An HTTP rule is written under `toPorts`, in `rules.http`.
- A denied HTTP request gets 403 from the proxy; a layer 4 drop gets no answer.
- Filters: `--protocol http`, `-t l7` and `--verdict DROPPED`.
- Applying a policy with the same name replaces its rules.

<!-- astrona:playground:destroy -->
