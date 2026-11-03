# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-03/labs/lab-01
```

## Step 1: Read the drop

Send one request from `cadet`, then look for its dropped flows.

```sh
kubectl -n starfleet exec cadet -- curl -s -o /dev/null -m 5 http://probe.starfleet:8080/get
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod starfleet/cadet --verdict DROPPED --last 5
```

The drop reason is a denied policy decision on ingress of the `probe`. The policy `probe-ingress` allows only the label `app=shuttle`.

## Step 2: Extend the policy

Save this as `probe-ingress-cadet.yaml`:

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
    - matchLabels:
        app: cadet
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
```

Apply it:

```sh
kubectl apply -f probe-ingress-cadet.yaml
```

## Step 3: Confirm

```sh
kubectl -n starfleet exec cadet -- curl -s -o /dev/null -m 5 -w "%{http_code}\n" http://probe.starfleet:8080/get
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --type policy-verdict --from-pod starfleet/cadet --last 5
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-03/labs/lab-01
```
