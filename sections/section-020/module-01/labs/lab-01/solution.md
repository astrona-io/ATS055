# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-01/labs/lab-01
```

## Step 1: Replace the policy

Save this as `probe-ingress-http.yaml`. The `rules.http` block makes the Cilium agent send matching traffic through its Envoy proxy, which also makes it visible.

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

## Step 2: Apply it

Apply the file.

```sh
kubectl apply -f probe-ingress-http.yaml
```

## Step 3: Send both requests

The first request matches the rule. The second one does not.

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe.starfleet:8080/get
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe.starfleet:8080/headers
```

## Step 4: Read the HTTP flows

Filter for Layer 7 flows of the HTTP protocol.

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --type l7 --protocol http --from-pod starfleet/shuttle --last 20
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-01/labs/lab-01
```
