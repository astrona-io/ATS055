# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Add the HTTP rule

Save this as `probe-ingress-http.yaml`.

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

## Step 2: Add the DNS visibility policy

Save this as `shuttle-egress.yaml`.

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

## Step 3: Apply both files

Apply the two policies.

```sh
kubectl apply -f probe-ingress-http.yaml
kubectl apply -f shuttle-egress.yaml
```

## Step 4: Enable the httpV2 metric

Add the metric to the Cilium ConfigMap, set the metrics server address and restart the agents.

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"httpV2","hubble-metrics-server":":9965"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

## Step 5: Send traffic and read the flows

Send both requests, then read the Layer 7 flows.

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/get
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/headers
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --type l7 --from-pod starfleet/shuttle --last 20
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/capstone/labs/lab-01
```
