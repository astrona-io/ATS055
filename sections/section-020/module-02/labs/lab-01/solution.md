# Solution

Solve this lab on `terminal`. Each step ends with a check you can run, and the whole task ends with `astrona submit`. The steps below were written from the documentation and have not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Write the egress policy

Save this as `shuttle-egress.yaml`. A policy with an `egress` section turns on egress enforcement for `shuttle`, so it must list the probe as well as DNS.

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

## Step 2: Apply it

Apply the file.

```sh
kubectl apply -f shuttle-egress.yaml
```

## Step 3: Send a request by name

The lookup of the name goes through the DNS proxy of the Cilium agent.

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -m 5 -w "%{http_code}\n" http://probe.starfleet:8080/get
```

## Step 4: Read the DNS flows

Filter for Layer 7 flows of the DNS protocol.

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --type l7 --protocol dns --from-pod starfleet/shuttle --last 20
```

## Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-02/labs/lab-01
```
