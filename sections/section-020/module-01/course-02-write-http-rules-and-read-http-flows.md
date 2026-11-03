# Write HTTP Rules And Read HTTP Flows

Knowing that a layer 7 rule turns on the proxy is not enough. You must write the rule so that it allows what the application needs, and you must read the flows it produces. This part changes the existing policy to add an HTTP rule, tests an allowed and a denied request, and reads the HTTP flows with their verdicts.

## The fields of an HTTP rule

An HTTP rule sits under `toPorts` of an ingress or egress rule, in a block called `rules` with the key `http`. Each entry in the list is one allowed request shape. A request is allowed if it matches at least one entry. The fields of an entry are:

- `method`: the HTTP method, for example `GET` or `POST`. It is a regular expression.
- `path`: the URL path. It is an extended regular expression that must match the whole path.
- `host`: the value of the host header, also a regular expression.
- `headers`: a list of header names or header values that the request must carry.

An entry can combine fields, and then the request must match all of them. If you leave a field out, it matches anything. An entry with only `method: GET` allows any path with the method GET.

Because the match is a regular expression, characters such as `.` and `*` have a special meaning. The path `/get` matches exactly `/get` and does not match `/get/1` or `/getaway`. To allow everything under a prefix, you write a pattern such as `/get/.*`.

## Add the rule to the policy

The goal is to let `shuttle` send only `GET` requests for the path `/get` to the `probe`. Save the changed policy as `probe-ingress-http.yaml`. It has the same name as the existing policy, so applying it replaces the old rules:

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
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
      rules:
        http:
        - method: GET
          path: /get
```

Apply it:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f probe-ingress-http.yaml
```

The Cilium agent compiles the policy, updates the endpoint of the `probe` and starts redirecting port 8080 traffic of that endpoint to the proxy. This takes a few seconds. Then check that the policy exists with the rule:

```sh
kubectl -n starfleet get cnp probe-ingress -o jsonpath='{.spec.ingress[0].toPorts[0].rules.http}'
```

The command prints the list with the method `GET` and the path `/get`.

## Test an allowed and a denied request

Send two requests from `shuttle`. The first matches the rule. The second uses the same method and port but a different path:

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe:8080/get
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe:8080/headers
```

The first request prints `200`: the proxy matched the rule and forwarded it, and the `probe` answered. The second request prints `403`: the proxy did not find a matching entry and answered with the status 403 (Forbidden) itself. The `probe` never saw that request.

This is a difference from layer 4. At layer 4 a denied connection is dropped and the client usually waits until it times out. At layer 7, the client gets an immediate HTTP answer, because the proxy has a complete HTTP connection to the client and can reply.

Now send a request from the `drifter` pod in the namespace `outpost`. Its identity is not in the `fromEndpoints` list, so the layer 4 part of the policy denies it before any HTTP rule is considered:

```sh
kubectl -n outpost exec drifter -- curl -s -m 5 -o /dev/null -w "%{http_code}\n" http://probe.starfleet:8080/get
```

The request does not get an HTTP answer. The `-m 5` option stops after 5 seconds, and `curl` prints `000`, which means no HTTP status was received. The connection was dropped by the datapath, not rejected by the proxy.

## Read the HTTP flows

Layer 7 flows are selected with the type filter and the protocol filter. Read the HTTP flows of the `probe` for the last minute:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --pod starfleet/probe --protocol http --since 1m
```

Each HTTP event appears as its own flow. The documentation shows the format of such lines, with the method and the URL in brackets after the verdict:

```text
http-request FORWARDED (HTTP/1.1 GET http://web/)
```

For the denied request, the line has the verdict `DROPPED`. The documentation shows a dropped HTTP line like this:

```text
default/tiefighter:42742 -> default/deathstar-c74d84667-cx5kp:80 http-request DROPPED
```

Your lines use your own pod names. You find one `http-request` line with `FORWARDED` for `/get` and one `http-request` line with `DROPPED` for `/headers`. The forwarded request also has a response flow with the HTTP status code, and the response flow carries the latency.

To see only the denied requests, filter on the verdict:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --pod starfleet/probe --protocol http --verdict DROPPED --since 1m
```

The list shows only the `/headers` request. The request from `drifter` does not appear here, because it never reached the proxy. It appears as a layer 4 drop, which you can find with `--verdict DROPPED` without the protocol filter.

## Reading the result correctly

Two different kinds of drop now exist for the same service. A layer 4 drop comes from the kernel programs and has no HTTP fields. A layer 7 drop comes from the proxy and has the method and URL. The type of the flow tells you which component made the decision, and therefore which part of the policy to change. If you want to allow `/headers` for `shuttle`, you add an entry to the `http` list. If you want to allow `drifter`, you add a source under `fromEndpoints`.

You also see why an HTTP rule needs care. If you apply a rule that lists only `GET /get`, any other call that the client used before, such as a `POST`, now fails with 403. Before you apply such a rule to a production service, you read the layer 7 traffic first, for example in a policy that allows all paths, and then narrow it.

You now know how to write an HTTP rule, how a denied request looks to the client and in Hubble, and how to separate layer 4 and layer 7 drops. Another kind of layer 7 traffic is the DNS lookup that happens before the request is sent.

## Common pitfalls

> [!WARNING]
> A request that does not match any HTTP entry gets 403, so a rule that is too narrow breaks working clients. Method and path are regular expressions, so `.` and `*` have a special meaning and the path must match completely. Applying a policy with the same name replaces the old rules; keep every rule you still need. A layer 4 drop for another source never reaches the proxy and has no HTTP fields in its flow.
