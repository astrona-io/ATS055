# HTTP Rule Matching: Method, Path And Headers

An HTTP rule decides which requests the proxy lets through. A rule that is too wide allows requests that you wanted to block, and a rule that is too narrow breaks the application. This part explains each field of an HTTP rule, how the fields combine, and how to test a rule against real requests.

## The fields

An HTTP rule is an entry under `toPorts` and `rules.http` in a `CiliumNetworkPolicy`. Each entry can have these fields:

- `method`: the HTTP method, written as a regular expression, for example `GET` or `GET|HEAD`.
- `path`: the request path, written as a regular expression, for example `/get`. A path must begin with `/`. The expression is matched against the whole path, so `/get` does not match `/get/1`. To allow sub-paths, write `/get/.*`.
- `host`: the value of the `Host` header, written as a regular expression.
- `headers`: a list of strings such as `X-Crew: true`. The request must carry each of these headers with that value.
- `headerMatches`: a list of objects with `name`, `value` and an optional `mismatch` action, for matching headers with more control.

Fields inside one entry combine with AND: a request must match the method, the path and every header. Several entries combine with OR: a request that matches any entry is allowed. A request that matches no entry gets the answer `403 Access denied` from the proxy, and Hubble records a dropped HTTP flow.

## Example with two entries

This policy allows `shuttle` to send `GET /get` and also `GET /headers`, but only when the header `X-Crew` has the value `true`. Save this as `probe-ingress-http.yaml`:

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
        - method: GET
          path: /headers
          headers:
          - "X-Crew: true"
```

Apply it:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f probe-ingress-http.yaml
```

Then check the result with three requests. Each prints the status code:

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe.starfleet:8080/get
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe.starfleet:8080/headers
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" -H "X-Crew: true" http://probe.starfleet:8080/headers
```

The first request matches the first entry and returns `200`. The second request reaches the path `/headers` without the header, so it matches no entry and returns `403`. The third request matches the second entry and returns `200`.

## Regular expression traps

The `path` field is a regular expression, not a prefix. The character `.` matches any character, so `/v1.0` also matches `/v1x0`. A slash at the end changes the match: `/get/` is not `/get`. If your application accepts query strings, the proxy matches the path without the query, so a rule for `/get` also covers `/get?id=1`.

The method is also a regular expression, so `GET` matches only `GET`, but a rule such as `G.*` matches `GET` and also any other method that starts with G. Keep expressions as exact as the requirement allows.

You now know how a request is matched. The remaining task is to prove, with flows, that a rule does what you intended.

## Common pitfalls

> [!WARNING]
> A rule without a `path` allows every path for that method. A rule with only a `path` allows every method. Paths that differ only by case or by a trailing slash do not match each other. A policy that is applied with `kubectl apply` replaces the earlier rules of the same name, so include every allowed source again.
