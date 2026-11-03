# Proxy Cost And Troubleshooting

Layer 7 visibility has a price. Every request on a selected port goes through a proxy and uses processor time, memory and some latency. When a layer 7 flow is missing or a request fails after a policy change, you need a short list of checks. This part gives both.

## What it costs

Traffic without a layer 7 rule stays in the kernel and uses no proxy. Traffic with a rule makes an extra hop through Envoy on the same node. Envoy parses each request, evaluates the rules and reports an event. The cost grows with the request rate and with the number of rules. Because one Envoy serves a whole node, one busy service can slow the layer 7 traffic of the other services on that node.

The practical advice is to select only what you need. Put an HTTP rule on the ports of the services that you must observe, not on every port of the cluster. Watch the processor and memory use of the Envoy pods (or the agent pods) after you widen a rule.

## The visibility annotation

Older Cilium releases had a pod annotation, `policy.cilium.io/proxy-visibility`, that redirected a port to the proxy for visibility without writing a rule. This is the legacy way. Current documentation steers users to policy rules, because a rule makes the intent explicit and an annotation can hide that a port goes through the proxy. If you meet the annotation in an old cluster, treat it as a reason to check which ports are proxied.

## A checklist for a missing flow

Work from the bottom up. The first check is the policy: does a rule with `toPorts` and `rules` select the pod and the port? The second is the protocol: is the traffic plain HTTP or DNS, not TLS? The third is the endpoint: does the agent list the pod with policy enforcement on?

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg endpoint list
```

The endpoint list shows, for each endpoint, whether ingress and egress policy enforcement is enabled. An endpoint without enforcement for the direction that your rule covers cannot produce layer 7 flows. The fourth check is the time: did you read the flows after the request, and is the buffer large enough to still hold them? Run the filter again with a short `--since` window:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --protocol http --since 2m
```

The fifth check is the proxy itself. Look at the log of the agent or the Envoy pod for errors after the policy change:

```sh
kubectl -n kube-system logs ds/cilium -c cilium-agent --since=5m | grep -i -E "proxy|envoy|error"
```

## A failure after a policy change

If requests that worked now return `403`, the new rule is narrower than the traffic. Use the HTTP filters to see the refused method and path, and add them to the rule. If requests now hang, the proxy may not be ready, or the traffic uses a protocol that the proxy cannot parse on that port. Remove the layer 7 rule to confirm: if the requests work again, the proxy path is the cause.

You now have a cost model, a legacy warning and a checklist. They complete the picture of layer 7 visibility: it gives detail for plain, selected traffic, it can be counted, and it costs resources.

## Common pitfalls

> [!WARNING]
> A rule on a port that carries a protocol the proxy cannot parse can break the service. A wide layer 7 rule on a busy port raises the load of the node. Checking only the flows can miss that the policy never selected the pod, so read the endpoint list as well. Do not remove a layer 7 rule to fix a `403` without understanding the traffic, because the same rule may also protect the service.
