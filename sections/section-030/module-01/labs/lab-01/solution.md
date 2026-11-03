# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-01/labs/lab-01
```

## Step 1: Look at the dropped flows

Filter for the verdict DROPPED towards the probe.

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --to-pod starfleet/probe --verdict DROPPED --last 20
```

## Step 2: Write the report

The source in the output is `outpost/rogue`. The destination is `starfleet/probe` on port 8080.

```sh
kubectl -n starfleet create configmap cli-report --from-literal=dropped-source=outpost/rogue --from-literal=destination=starfleet/probe --from-literal=destination-port=8080 --from-literal=verdict=DROPPED
```

## Step 3: Allow only rogue

Save this as `probe-ingress-rogue.yaml`. The second source names both the pod label and the namespace, so `drifter` stays refused.

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
  - fromEndpoints:
    - matchLabels:
        app: rogue
        io.kubernetes.pod.namespace: outpost
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
```

## Step 4: Apply it and check

Apply the file, wait a few seconds and look for forwarded flows from `rogue`.

```sh
kubectl apply -f probe-ingress-rogue.yaml
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod outpost/rogue --since 30s
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-01/labs/lab-01
```
