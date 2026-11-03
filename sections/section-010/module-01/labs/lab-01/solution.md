# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-01/labs/lab-01
```

## Step 1: Send one request from each client

The policy allows `shuttle` and not `drifter`, so the two requests end differently.

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -m 5 -w "%{http_code}\n" http://probe.starfleet:8080/get
kubectl -n outpost exec drifter -- curl -s -o /dev/null -m 5 -w "%{http_code}\n" http://probe.starfleet:8080/get
```

## Step 2: Find the flows

Run `hubble observe` inside the Cilium agent pod. The `--from-pod` filter takes `namespace/pod`.

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --to-pod starfleet/probe --last 20
```

## Step 3: Write the report

The forwarded flow comes from `starfleet/shuttle`. The dropped flow comes from `outpost/drifter`, with the reason Policy denied, on destination port 8080.

```sh
kubectl -n starfleet create configmap flow-report \
  --from-literal=forwarded-source=starfleet/shuttle \
  --from-literal=dropped-source=outpost/drifter \
  --from-literal='drop-reason=Policy denied' \
  --from-literal=dropped-destination-port=8080
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-01/labs/lab-01
```
