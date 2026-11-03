# Question

Solve this question on: `terminal`

The team wants to see which names the pod `shuttle` in `starfleet` looks up. The cluster DNS runs in the pods labelled `k8s-app=kube-dns` in `kube-system`.

1. Create a `CiliumNetworkPolicy` for `shuttle` that sends its DNS traffic (UDP and TCP port 53) to the cluster DNS with a DNS rule that matches every name.
2. Keep `shuttle` able to reach the `probe` on TCP port 8080.
3. Send a request from `shuttle` to `http://probe.starfleet:8080/get` and find the DNS query in Hubble.

Do not change the `probe-ingress` policy.

`kubectl` already points at the cluster as the cluster administrator.
