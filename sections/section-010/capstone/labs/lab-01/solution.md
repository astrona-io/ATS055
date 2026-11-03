# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/capstone/labs/lab-01
```

## Step 1: Change the Hubble settings

Merge all three keys into the Cilium ConfigMap and restart the agents.

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"drop flow","hubble-metrics-server":":9965","hubble-event-buffer-capacity":"16383"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

## Step 2: Find the dropped flows

Filter for DROPPED flows towards the probe.

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --to-pod starfleet/probe --verdict DROPPED --last 20
```

## Step 3: Write the report

The source is `outpost/rogue`, the destination `starfleet/probe`, the port 8080 and the reason Policy denied.

```sh
kubectl -n starfleet create configmap drop-report --from-literal=source=outpost/rogue --from-literal=destination=starfleet/probe --from-literal=port=8080 --from-literal='reason=Policy denied'
```

## Step 4: Read the metric

Use the Kubernetes API proxy to reach port 9965 of the agent.

```sh
pod=$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" | grep hubble_drop_total
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/capstone/labs/lab-01
```
