# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Repair the UI

The Deployment has no replicas and the Service selector is wrong.

```sh
kubectl -n kube-system scale deployment/hubble-ui --replicas=1
kubectl -n kube-system patch service hubble-ui --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"k8s-app":"hubble-ui"}}]'
kubectl -n kube-system rollout status deployment/hubble-ui --timeout=300s
```

## Step 2: Find the dropped flows

Filter for the verdict DROPPED.

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --to-pod starfleet/probe --verdict DROPPED --last 20
```

## Step 3: Write both reports

Create the two ConfigMaps.

```sh
kubectl -n starfleet create configmap cli-report --from-literal=dropped-source=outpost/rogue --from-literal=destination=starfleet/probe --from-literal=destination-port=8080 --from-literal=verdict=DROPPED
kubectl -n starfleet create configmap ui-report --from-literal=dropped-edge='outpost/rogue->starfleet/probe' --from-literal=namespaces=outpost,starfleet
```

## Step 4: Allow only rogue

Save this as `probe-ingress-rogue.yaml`, then apply it with `kubectl apply -f probe-ingress-rogue.yaml`.

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

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/capstone/labs/lab-01
```
