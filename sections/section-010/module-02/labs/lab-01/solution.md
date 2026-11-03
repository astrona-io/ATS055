# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-02/labs/lab-01
```

## Step 1: Edit the Cilium ConfigMap

Both settings are keys in `cilium-config`. The `hubble-metrics` value is a space-separated list.

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"drop flow","hubble-metrics-server":":9965","hubble-event-buffer-capacity":"8191"}}'
```

## Step 2: Restart the agents

The Cilium agent reads the ConfigMap at start, so restart the DaemonSet and wait.

```sh
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

## Step 3: Read the metric

The Kubernetes API proxy can reach port 9965 of the agent pod.

```sh
pod=$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" | grep hubble_drop_total
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-02/labs/lab-01
```
