# Write A DNS Rule And Read DNS Flows

A DNS rule is short, but a small mistake in it either hides the lookups or breaks the pod. This part writes the policy for `shuttle`, applies it, reads the DNS flows and then tests the limits of what layer 7 visibility can show.

## The fields of a DNS rule

A DNS rule sits under `toPorts` of an egress rule, in a block `rules` with the key `dns`. Each entry names the queries that are allowed. There are two fields:

- `matchName`: an exact name, for example `probe.starfleet.svc.cluster.local`. The name is written in full and without a trailing dot in the policy.
- `matchPattern`: a name with the wildcard `*`. The pattern `*` matches every name. The pattern `*.cluster.local` matches names under that domain.

A query that matches at least one entry is forwarded. A query that matches none is refused by the proxy. For visibility without restriction, you use `matchPattern: "*"`, so that every query is allowed and every query is recorded.

The rule must be attached to the port that carries DNS, and its target must be the DNS server. In Kubernetes that is the pod set with the label `k8s-app: kube-dns` in the namespace `kube-system`. The selector for a pod in another namespace must name the namespace through the label `io.kubernetes.pod.namespace`.

## Write the policy

The policy has two egress rules. The first sends the DNS traffic of `shuttle` to the cluster DNS, with the DNS rule. The second keeps the path to the `probe` on port 8080. Save this as `shuttle-egress.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: shuttle-egress
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: shuttle
  egress:
  - toEndpoints:
    - matchLabels:
        io.kubernetes.pod.namespace: kube-system
        k8s-app: kube-dns
    toPorts:
    - ports:
      - port: "53"
        protocol: UDP
      - port: "53"
        protocol: TCP
      rules:
        dns:
        - matchPattern: "*"
  - toEndpoints:
    - matchLabels:
        app: probe
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
```

The `endpointSelector` chooses the pod `shuttle`. The first egress rule lists both transports for port 53, so lookups over UDP and TCP are redirected to the DNS proxy. The second rule allows the TCP connection to the `probe`. Because the policy has egress rules, Cilium now denies all other egress of `shuttle`.

Apply it:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f shuttle-egress.yaml
```

Then check the result. Send a request by name and look at the status code:

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe.starfleet:8080/get
```

The command prints `200`. The lookup went through the DNS proxy, and the connection to the `probe` was allowed by the second rule. If the second rule were missing, the lookup would work and the connection would fail.

## Read the DNS flows

DNS flows are layer 7 flows with the protocol DNS. Filter for them:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --pod starfleet/shuttle --protocol dns --since 1m
```

Each query and each answer is one flow. The documentation shows the format of a query line:

```text
dns-request proxy FORWARDED (DNS Query web.default.svc.cluster.local. A)
```

The text in brackets has the query name, with a dot at the end, and the record type. The type `A` asks for an IPv4 address, and the type `AAAA` asks for an IPv6 address. Many resolvers ask for both, so you see two queries for each name. The verdict `FORWARDED` means that the rule allowed the query. A query that the rule refuses shows `DROPPED`.

Read the flows as a list of what the pod looked up: the name `probe.starfleet` expanded through the search domains, the type of each query and the verdict. If a request fails with a name error, this list tells you which name the resolver asked for and whether the cluster DNS answered.

To see the answers in detail, add `-o json` to one flow. The JSON has a `l7` section with a `dns` object that holds the query, the response code and the addresses in the answer.

## Test a narrower rule

You can also restrict the lookups. If you replace the pattern `*` by `matchName: probe.starfleet.svc.cluster.local`, only that name resolves, and every other lookup is refused. A refused query gets a response with the code `REFUSED` from the proxy, and the flow shows `DROPPED`. This shows the second use of a DNS rule: it controls which names a pod may resolve. The wildcard version in this part is only for visibility.

## The limits of layer 7 visibility

Layer 7 visibility reads only what the proxy can parse. Three limits matter in practice.

First, encryption. A request to an HTTPS address is encrypted between the client and the server. Cilium sees the DNS lookup for the server name, because that goes through the DNS proxy, but it cannot read the HTTP request after the TLS handshake. You can check this with a request to an external HTTPS address from `shuttle`: the DNS flow exists, and no HTTP flow exists. This request also needs a path to the internet, and the policy above does not allow one, so it fails here, which shows the effect of the egress enforcement.

Second, protocols. The proxy parses HTTP, DNS and a few other protocols. Other traffic, such as a database protocol over TCP, shows only as layer 4 flows.

Third, scope. Visibility exists only for the endpoints and ports that a layer 7 rule selects. All other pods show layer 4 flows only. To widen the view, you widen the rules, and you pay the cost of the proxy for that traffic.

You now have two kinds of layer 7 flows: HTTP requests and DNS lookups. You know that each needs a policy, that the policy restricts the traffic, and that encrypted and unsupported traffic stays at layer 4. The remaining step is to use both together and to count them with metrics.

## Common pitfalls

> [!WARNING]
> Forgetting the second egress rule breaks the connection to the `probe`, because the policy now denies everything that it does not list. A `matchName` must be a full name, so the short name `probe` does not match. A pattern with `*` is a visibility tool, not a safe restriction. A DNS flow does not show whether the later connection worked. An HTTPS request produces a DNS flow and no HTTP flow.
