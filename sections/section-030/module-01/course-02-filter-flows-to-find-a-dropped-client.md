# Filter Flows To Find A Dropped Client

A service owner reports that a client does not reach the service, and the client team says the service is down. Neither side has evidence. The flows give the evidence: which pod sent the traffic, which pod and port it targeted and what Cilium decided. This part follows a drop investigation from the symptom to a policy change, using combined filters, and shows how to record the result.

## Start from the verdict

When you do not know the affected pod, begin with the verdict and nothing else. A drop is the event you look for, so ask for dropped flows of the whole node:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --since 2m
```

The list can contain more than one kind of drop. Look at the first and second endpoint of each line, and at the drop reason. In the playground, the lines repeat every 5 seconds with the same source and destination. A repeating pattern with a fixed interval points to a client that retries or polls. The `rogue` pod sends a request every 5 seconds, so you see that rhythm in the timestamps.

Note three facts from a line: the source, the destination and the destination port. Then confirm them with a narrower filter, so that your conclusion rests on a filtered list and not on the first lines you saw:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --to-pod starfleet/probe --to-port 8080 --since 2m
```

The filters `--to-pod` and `--to-port` select flows that go to the `probe` on port 8080. The result lists the sources that are denied. It shows `outpost/rogue`. It may also show `outpost/drifter` if that pod sent a request in the window.

## Separate the sources

The drop list can hide the fact that one source drops and another source passes. Compare with the forwarded flows to the same destination:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict FORWARDED --to-pod starfleet/probe --to-port 8080 --since 2m
```

If `shuttle` sent a request in the window, it appears here with the verdict `FORWARDED`. The comparison shows that the policy discriminates by source: one source passes and the others do not. Without this check you could conclude that the `probe` is unreachable in general, which would send you in the wrong direction.

To send a request from `shuttle` and see it in the list, run it first, then run the command again:

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe:8080/get
```

The request prints `200`.

## Read the direction and the labels

For the decision, you need the labels of the source, because a policy selects by label and not by name. Take one dropped flow in JSON, and read the source labels. The tool `jq` extracts them:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --from-pod outpost/rogue --last 1 -o json
```

In the JSON, the `source.labels` list contains entries such as `k8s:app=rogue` and `k8s:io.kubernetes.pod.namespace=outpost`. Those are the labels that a `fromEndpoints` selector can use. The `traffic_direction` field says `INGRESS`, because the drop happened on the incoming side of the `probe`. That tells you the policy to change is the one that selects the `probe`, and not a policy on the `rogue` pod.

## Decide what to change

You have a finding: the pod labelled `app=rogue` in `outpost` is denied by the ingress policy of the `probe` on TCP port 8080. Before you change anything, state what you want. Suppose the `rogue` pod is a legitimate client, and only `drifter` should stay refused. Then the policy needs a second allowed source with the label `app: rogue`, and it must keep `shuttle` allowed.

A source in another namespace needs the namespace in its selector. A `fromEndpoints` entry with only `app: rogue` matches pods in the namespace of the policy, here `starfleet`, so it would not match the pod in `outpost`. You add the namespace label `io.kubernetes.pod.namespace: outpost` to the selector.

Save the changed policy as `probe-ingress-rogue.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-ingress
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: shuttle
    - matchLabels:
        app: rogue
        io.kubernetes.pod.namespace: outpost
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
```

Apply it:

```sh
kubectl apply -f probe-ingress-rogue.yaml
```

Then check the result. The flows of `rogue` to the `probe` change from `DROPPED` to `FORWARDED`, and the flows of `drifter` stay dropped when it sends a request:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod outpost/rogue --to-pod starfleet/probe --since 30s
```

The new flows from `rogue` show `FORWARDED`. Older lines in the window can still show `DROPPED` from before the change, so read the timestamps.

## Record the finding

A finding is useful when another person can use it. Write down the source, the destination, the port, the verdict and the time window, together with the filter that produced them. Some teams keep this in a ConfigMap or in a ticket. The facts to record for this case are `outpost/rogue` as the dropped source, `starfleet/probe` as the destination, `8080` as the port and `DROPPED` as the verdict.

You now have a method: start with the verdict, confirm with source, destination and port filters, compare with forwarded flows, read the labels, change the policy narrowly and check the flows again. The command line is the right tool for this when you know the pods. When you do not know the shape of the traffic, a service map gives a faster overview.

## Common pitfalls

> [!WARNING]
> A `fromEndpoints` selector without the namespace label matches only the namespace of the policy. A policy edit with the same name replaces all its rules, so keep every source that must still work. Old drops stay in the buffer after the change, so read the timestamps before you decide that the fix failed. Do not allow a source only because it is dropped; first decide that it should be allowed.
