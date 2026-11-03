# DNS And Name Problems

A failed name lookup looks like a failed connection to the application. The error says "cannot resolve host" or "connection timed out", and the first suspect is the network. Hubble shows DNS traffic as flows, so it can tell a lookup problem from a connection problem. This part applies the method to names.

## What a lookup needs

A pod sends a DNS query to the cluster DNS Service, which in Kubernetes is `kube-dns` in `kube-system` on port 53. The query goes over UDP, or over TCP when the answer is large. The DNS pods answer with the address. The pod then connects to that address.

Each of these steps can fail for a different reason. The query can be dropped by an egress policy of the client. The DNS pods can be unreachable or slow. The DNS pods can answer with an error because the name does not exist. A DNS proxy rule can refuse the name.

## Look at the DNS flows

Layer 4 flows to port 53 exist for every pod, even without a DNS rule. Read the flows of the client that goes to the DNS Service:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod starfleet/shuttle --to-port 53 --last 10
```

The `shuttle` pod looks up `probe.starfleet` before it connects. Flows to port 53 with the verdict `FORWARDED` show that the query left the pod. A `DROPPED` verdict shows that an egress policy of the client denied the query. In that case, the application error is "cannot resolve host", and the fix is a policy rule that allows egress to `kube-dns` on UDP and TCP port 53.

If the pod has a DNS rule, the layer 7 flows show names and response codes:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --protocol dns --last 10
```

The response codes tell the story. `NOERROR` is a successful answer. `NXDOMAIN` means that the name does not exist, so the fault is the name that the application uses, not the network. `REFUSED` means that a DNS rule or the DNS server refused the query. `SERVFAIL` means that the DNS server could not answer.

## Telling timeouts from refusals

A timeout and a refusal need different fixes. A refused query has a response flow with a code. A timeout has a query flow and no response. For a timeout, check that the DNS pods are ready and that the path to them is allowed in both directions:

```sh
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --to-pod kube-system/coredns --last 10
```

The label `k8s-app=kube-dns` is used by the cluster DNS pods, which are CoreDNS pods in a standard cluster. If the second command shows only dropped flows, the policy of the DNS pods or of the client denies the traffic.

## Names and search domains

A pod that asks for `probe.starfleet` sends several queries, because the resolver adds the search domains of the pod, such as `starfleet.svc.cluster.local`. Some queries return `NXDOMAIN` before one succeeds. This is normal and not an error. An application that uses the full name `probe.starfleet.svc.cluster.local.` with a final dot sends one query.

You now can separate name problems from connection problems. The last part of the method is about which tool to use when Hubble is not enough.

## Common pitfalls

> [!WARNING]
> `NXDOMAIN` for the search-domain variants of a name is normal. A name that works from one namespace can fail from another, because the short name depends on the search domains of the pod. A client with an egress policy that omits port 53 cannot resolve any name, and the application reports a network error. Checking only the connection to the address misses a lookup that never completed.
