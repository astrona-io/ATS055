# Advanced Flow Filters

A busy cluster produces thousands of flows. A good filter cuts them down to the few that answer your question. Earlier filters used the pod name and the verdict. This part adds the filters for time, direction, identity, labels, protocol and ports, and shows how to combine them and how to negate one.

## Filters by time and amount

The options `--last N` and `--first N` return the newest or the oldest N flows. The option `--since 5m` returns flows from the last five minutes, and `--until 1m` stops at one minute ago. The option `--follow` (or `-f`) keeps the command running and prints new flows as they arrive. The option `--all` prints every flow in the buffer.

A common pattern is to start a follow in one terminal and run the failing request in another. The new flows then appear while you test.

## Filters by endpoint

Pod filters are `--from-pod` and `--to-pod`, and `--pod` matches the pod on either side. The option `--namespace` matches either side by namespace. Label filters are `--from-label`, `--to-label` and `--label`, and they take the label as it appears in the flow, for example `--from-label k8s:app=rogue`. Identity filters are `--from-identity`, `--to-identity` and `--identity`. Address filters are `--from-ip` and `--to-ip`. Name filters are `--from-fqdn` and `--to-fqdn` and match the names that the DNS proxy saw.

## Filters by traffic type

The option `--protocol` accepts `tcp`, `udp`, `icmp`, `http`, `dns` and others. The option `--port`, with `--from-port` and `--to-port`, matches ports. The option `--traffic-direction` takes `ingress` or `egress` and shows the direction that the policy decision applied to. The option `--type` selects the event type: `trace`, `drop`, `policy-verdict`, `l7` and others. The option `--tcp-flags` selects packets with a TCP flag such as `SYN` or `RST`.

The options `--http-method`, `--http-path` and `--http-status` select HTTP flows. The option `--verdict` takes `FORWARDED`, `DROPPED`, `ERROR`, `AUDIT` or `REDIRECTED`. The option `--drop-reason-desc` selects flows with a given drop reason.

## Combine and negate

Different options combine with AND. This command shows dropped flows from the label `app=rogue` to port 8080:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --from-label k8s:app=rogue --to-port 8080 --last 5
```

Repeating the same option gives OR. The next command shows dropped flows from either of two pods:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --from-pod outpost/rogue --from-pod outpost/drifter --last 10
```

The option `--not` negates the filters that follow it, until the next filter group. Use it to hide noise. This command shows flows in the `starfleet` namespace that are not forwarded:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --namespace starfleet --not --verdict FORWARDED --last 10
```

A filter on the source and a filter on the destination in the same command must both hold. If you want flows in either direction between two pods, run two commands, or use the `--pod` option, which matches either side.

## Choose by question

For a policy question, start with `--type policy-verdict` and `--verdict DROPPED`. For a name resolution question, use `--protocol dns`. For a slow or reset connection, use `--tcp-flags RST` with `--to-pod`. For a request question, use `--protocol http` with `--http-status`. Start narrow, and widen the filter only if the result is empty.

You now can find the right flows quickly. When the command line is less useful because you do not know where to look, the Hubble UI draws the same data as a map.

## Common pitfalls

> [!WARNING]
> Labels in filters need the source prefix, so `app=rogue` without `k8s:` can match nothing. `--not` applies to the filters after it, so place it carefully. An empty result can mean a filter that is too narrow, an old event or a different node. A command with `--follow` and no `--last` can start with a long backlog.
