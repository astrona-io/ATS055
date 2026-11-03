# Verify HTTP Visibility And Verdicts

A policy that looks right can still fail in practice. The only proof is the traffic that actually passed or was refused. This part reads the HTTP flows that the policy from the earlier part produced and uses the HTTP filters of `hubble observe` to answer three questions: what was requested, what was the answer and which rule decided.

## The HTTP filters

Hubble can filter layer 7 flows by their HTTP fields. The options of `hubble observe` that you need are:

- `--protocol http` selects HTTP flows.
- `--http-method GET` selects one method.
- `--http-path /headers` selects a path (a regular expression).
- `--http-status 403` selects a status code. A pattern such as `4+` selects all client errors, and `5+` selects server errors.
- `--type l7` selects layer 7 events in general.

Send the same three requests as before, then look at the flows of `shuttle`:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/get
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/headers
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod starfleet/shuttle --protocol http --last 10
```

Each request creates two flows: one for the request and one for the response. The request flow shows the method and the URL. The response flow shows the status code and the time the answer took. A request that the policy refuses shows the verdict `DROPPED`, and the response flow shows the status `403`.

## Find only the refused requests

To see only refused requests, filter by the status:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --protocol http --http-status 403 --last 10
```

Every line is a request that the proxy answered with `403`. Read the method and the URL on each line and compare them with the `http` rules of the policy. A refused request that you expected to pass shows which field of the rule did not match: the method, the path or a header.

To read all fields of one flow, use JSON output with one flow:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --protocol http --http-status 403 --last 1 -o json
```

The `l7` object contains the `http` object with `code`, `method`, `url`, `protocol` and the list `headers`. The `type` is `REQUEST` or `RESPONSE`. Note that `url` holds the full URL that the client used, with the host name.

## Layer 4 flows still exist

The proxy does not replace the layer 4 flows. A request that the policy allows also creates a layer 4 flow that goes to the proxy. When you see a forwarded layer 4 flow and a dropped HTTP flow for the same request, the connection was allowed and the proxy refused the request inside it. This is the normal picture for an HTTP rule that denies a path.

You now have a check loop: apply the policy, send the request, filter the flows by status, and compare. The loop turns a guess into evidence.

## Common pitfalls

> [!WARNING]
> `--http-path` is a regular expression, so a path with special characters needs escaping. A request that never reached the proxy, such as one dropped by layer 4 policy, has no HTTP flow at all. Old flows stay in the buffer, so read the timestamps. The status `403` can also come from the application itself, so check which flow has the verdict `DROPPED` before you blame the policy.
