# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-03/labs/lab-01
```

## Step 1: Edit the Cilium ConfigMap

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"httpV2","hubble-metrics-server":":9965"}}'
```

## Step 2: Restart the agents

The agent reads the ConfigMap at start, so restart the DaemonSet and wait.

```sh
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

## Step 3: Send requests and read the counter

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/get
pod=$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" | grep hubble_http_requests_total
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-03/labs/lab-01
```
