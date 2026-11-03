# DNS Proxy Behaviour And Limits

The DNS proxy is a component in the Cilium agent that every DNS query of a selected pod passes through. Its behaviour explains several surprises: why a connection works for a while after a policy change, why a lookup over an unusual transport is not visible, and why a name can resolve to an address that is not allowed. This part explains the cache, the time to live and the limits.

## The FQDN cache

When the proxy forwards an answer, the agent stores the pair of name and address in the FQDN cache of the node. The `toFQDNs` rules use the cache to decide which addresses are allowed. Each entry has an expiry time that comes from the time to live (TTL) of the DNS answer. After the TTL passes, the entry expires and the address is no longer allowed, unless a newer lookup renewed it.

The agent also has a minimum TTL setting, so very short TTLs do not make the allowed addresses disappear faster than the connections can use them. The agent keeps the address allowed for as long as a connection that was opened with it is still open.

Read the cache of a node:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg fqdn cache list
```

The list shows the endpoint, the name, the addresses and the expiry time. The cache has entries only for pods that a DNS rule selects, because only those queries pass the proxy. If the list is empty, apply a policy with a DNS rule and send a request first.

## What the proxy cannot see

The proxy parses DNS over UDP and TCP on the port named in the rule. It cannot see a lookup that does not use that port. A pod that sends queries over HTTPS to a public resolver (DNS over HTTPS) hides the names inside encrypted web traffic, so no DNS flow exists and no `toFQDNs` rule learns the address. A pod that queries a DNS server on another port is also outside the rule unless you list that port.

The proxy also does not see names that a pod never looks up. An application with a built-in list of IP addresses connects directly, and Hubble shows only a layer 4 flow with the destination address.

## Failure cases

If the cluster DNS is slow or unreachable, the proxy cannot forward the query, and the pod sees a timeout. Hubble shows the query without a response. If a DNS rule is too narrow, the proxy refuses the query at once, and Hubble shows a dropped flow and the response code `REFUSED`. Telling the two cases apart is quick: a refused query has a response flow, and a timeout has none.

A third case follows from the cache. A pod can reach an address after a policy that removed its name, because the cache entry is still valid and an open connection is kept. The access ends after the entry expires and the connection closes.

Read the DNS flows of the pod to see queries and responses together:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --pod starfleet/shuttle --protocol dns --last 10
```

You now know the whole path of a name: the query passes the proxy, the answer enters the cache, and the cache decides which connection is allowed for how long.

## Common pitfalls

> [!WARNING]
> A short TTL does not mean an address is blocked at that second, because the agent keeps an address allowed while a connection that used it is open. DNS over HTTPS bypasses the DNS proxy. An empty FQDN cache usually means that no policy selects the pod for DNS, not that Cilium is broken. The proxy sees only the port that the rule names.
