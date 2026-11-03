# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Inspect the Deployment and the Service

Look at the replicas of the Deployment and at the selector of the Service.

```sh
kubectl -n kube-system get deployment hubble-ui
kubectl -n kube-system get service hubble-ui -o jsonpath='{.spec.selector}'
kubectl -n kube-system get pods -l k8s-app=hubble-ui --show-labels
```

## Step 2: Repair both faults

Scale the Deployment back to one replica and restore the selector to the label the pods carry.

```sh
kubectl -n kube-system scale deployment/hubble-ui --replicas=1
kubectl -n kube-system patch service hubble-ui --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"k8s-app":"hubble-ui"}}]'
kubectl -n kube-system rollout status deployment/hubble-ui --timeout=300s
```

## Step 3: Write the report

The dropped edge is the one from `rogue` to the `probe`. The map has the two namespaces `outpost` and `starfleet`.

```sh
kubectl -n starfleet create configmap ui-report --from-literal=dropped-edge='outpost/rogue->starfleet/probe' --from-literal=namespaces=outpost,starfleet
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-02/labs/lab-01
```
