# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-03/labs/lab-01
```

## Step 1: Edit the Cilium ConfigMap

The export file path and the allow list are keys in `cilium-config`. The allow list is a JSON filter.

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-export-file-path":"/var/run/cilium/hubble/events.log","hubble-export-allowlist":"{\"verdict\":[\"DROPPED\"]}"}}'
```

## Step 2: Restart the agents

The agent reads the keys at start, so restart the DaemonSet and wait.

```sh
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

## Step 3: Read the file

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- tail -n 2 /var/run/cilium/hubble/events.log
```

Each line is one JSON object, and its verdict is `DROPPED`.

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-03/labs/lab-01
```
