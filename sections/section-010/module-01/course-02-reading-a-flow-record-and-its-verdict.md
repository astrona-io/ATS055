# Reading A Flow Record And Its Verdict

A flow line packs many facts into one row: who sent the traffic, who received it, which protocol and port, which direction, and what Cilium did with it. If you read only the colour of the word at the end, you can reach a wrong conclusion. This part takes one flow apart field by field, shows the verdict values, and explains what a verdict proves and what it does not prove.

## The fields of a flow

Every flow is a structured record. The command-line tool prints it as one line by default, and as full JSON (JavaScript Object Notation) when you add `-o json`. The same fields exist in both forms. These are the ones you use most:

| Field | What it holds |
| --- | --- |
| `time` | When the event was observed on the node |
| `source` and `destination` | The endpoint at each end: IP address, namespace, pod name, labels, and the Cilium identity |
| `l4` | The transport protocol (TCP, UDP or ICMP) and the ports |
| `IP` | The source and destination IP addresses and the IP version |
| `traffic_direction` | `INGRESS` or `EGRESS`, seen from the endpoint where the event happened |
| `is_reply` | Whether the packet belongs to the reply direction of a connection |
| `verdict` | What Cilium decided: forwarded, dropped and so on |
| `drop_reason_desc` | The reason, present only when the verdict is a drop |
| `Type` | Whether the flow is a layer 3 or 4 event or a layer 7 event |
| `Summary` | A short human-readable text, for example the TCP flags |

A Cilium **identity** is a number that Cilium assigns to a set of labels. All pods with the same labels share one identity. Policy decisions use identities, not IP addresses, which is why a flow can show `(ID:95552)` next to a name.

## Reading one forwarded flow

In the playground, the `shuttle` pod is allowed to reach the `probe`. Send one request from it, then ask for the flows between the two pods:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe:8080/get
```

The command prints the HTTP status code that the `probe` answers. It is `200` when the request is allowed. Now read the flows from that pod:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod starfleet/shuttle --last 10
```

Each line follows the same layout: a timestamp, the source with its port, an arrow, the destination with its port, the trace point, the verdict, and a summary. The Hubble documentation shows this layout with a forwarded line:

```text
Feb 12 19:13:58.111: kube-system/hubble-relay-6467f4f4d-xrxfs:47550 (ID:95552) -> 172.18.0.2:4244 (host) to-stack FORWARDED (TCP Flags: ACK, PSH)
```

Read it from left to right. The source is the pod `hubble-relay-6467f4f4d-xrxfs` in `kube-system`, sending from port 47550. The destination is the node address `172.18.0.2` on port 4244, and Cilium labels it `host`. The word `to-stack` is the trace point: the packet leaves the Cilium datapath toward the network stack of the node. `FORWARDED` is the verdict. The text in brackets lists the TCP flags set on that packet.

A single request produces several flows, not one. A TCP connection has a handshake, data packets and a close, and each event can be observed at more than one point. The traffic also has two directions: the request and the reply. The `is_reply` field separates them, and the filter `--reply` shows only reply packets while `--not-reply` shows only the ones that start the connection.

## The verdict values

The verdict is the decision or the outcome that Cilium recorded for that event. These are the values you will meet:

- `FORWARDED`: the datapath let the packet through.
- `DROPPED`: the datapath or a policy discarded the packet.
- `ERROR`: the datapath hit an error while handling the packet.
- `AUDIT`: a policy would have dropped the packet, but the endpoint runs in audit mode, so the packet passed.
- `REDIRECTED`: the packet was sent to a proxy, for example the Envoy proxy that handles layer 7 rules.
- `TRACED` and `TRANSLATED`: informational events, for example when a Service address was translated to a pod address.

A dropped flow also carries a drop reason. When a policy denies the traffic, the reason is a policy denial. Other drop reasons exist, such as an invalid packet or a missing endpoint, and each points to a different cause.

## Reading one dropped flow

The `rogue` pod in `outpost` sends a request to the `probe` every 5 seconds, and the `probe-ingress` policy does not allow it. Filter on the verdict to see only the drops:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --last 5
```

The lines show the source `outpost/rogue`, the destination `starfleet/probe` on port 8080, the verdict `DROPPED` and the drop reason. The destination port matters: the policy allows only `shuttle` to port 8080, so the drop happens on the ingress side of the `probe`, seen at the endpoint of the `probe`.

For the full record, ask for JSON for one flow and read the fields directly:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --last 1 -o json
```

In the JSON you find `verdict` set to `DROPPED`, `drop_reason_desc` set to the reason, `traffic_direction`, and the `source` and `destination` objects. The `labels` list in each object shows the labels that the policy matched on, such as `k8s:app=rogue`.

## What a verdict proves and what it does not

A `FORWARDED` flow proves that the datapath let a packet pass. It does not prove that the application received it, that the server answered, or that the answer was correct. A server can accept the connection and then return an HTTP 500 error, and the layer 3 and 4 flows still read `FORWARDED`. Only a layer 7 flow, which the proxy records, shows the HTTP status, and that needs the visibility that a later module sets up.

A `DROPPED` flow proves that the datapath discarded a packet. It does not tell you whether the drop is a fault or the intended effect of a policy. Here the drop is the policy working, so the right action is not to remove the policy. You compare the drop with what the policy is supposed to allow.

The absence of a flow proves less than you may think. The ring buffer may have replaced the event, the client may have been connected to a different node, or a filter may have excluded it. A flow you expect but cannot find is a reason to widen the filter and check the buffer, not a proof that no traffic existed.

You can now read a flow record: the endpoints, the protocol, the direction, the verdict and the drop reason, and you know the limits of each. The open question is how to keep more of these records and how to count them over time, which needs a larger buffer and metrics.

## Common pitfalls

> [!WARNING]
> Do not read `FORWARDED` as "the request succeeded"; it only means the packet passed the datapath. Do not read `DROPPED` as a fault before you check the policy that selects the endpoint. Reply packets have their own flows, so a missing reply flow and a missing request flow mean different things. When you filter with `--from-pod`, you see only flows whose source is that pod, so drops on the destination side need `--to-pod` or `--verdict`.
