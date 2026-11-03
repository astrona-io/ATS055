# Summary

Layer 7 visibility comes from the Envoy proxy, and it has clear limits. The proxy reads HTTP, gRPC over HTTP/2 and DNS in policy rules. A rule selects traffic by port, and only the selected traffic goes through the proxy. All other traffic, and every protocol that the proxy cannot parse, shows only layer 3 and layer 4 flows.

## What you learned

Encrypted traffic hides the request. A connection to an HTTPS server shows a layer 4 flow and, when the client looked up the name through the DNS proxy, a DNS flow. The method, path and status are not visible, and an HTTP rule cannot match them. The options are to terminate TLS before the pods, to use TLS inspection in the policy with a trusted certificate authority, or to accept the limit.

The `httpV2` and `dns` metric groups turn layer 7 events into counters: request counts, durations, DNS queries and responses. Their series appear only after layer 7 traffic passes the proxy. Label contexts decide the number of series, so stable labels such as the namespace and the workload are safer than addresses, pod names or query names.

The proxy costs processor time, memory and latency, and one Envoy serves a whole node. A missing layer 7 flow is found by checking the policy, the protocol, the endpoint enforcement, the time window and the logs, in that order.

## Key facts

- Only HTTP, gRPC and DNS are parsed in policy rules, and the Kafka parser is deprecated.
- A layer 7 rule on a port applies to every request on that port.
- TLS hides the request from Hubble unless the proxy terminates the TLS.
- Counters need an agent restart after a change of the metric list.

<!-- astrona:playground:destroy -->
