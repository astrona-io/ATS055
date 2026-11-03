# Question

Solve this question on: `terminal`

The Hubble UI is installed in `kube-system`, but nobody can open it. Repair it, then use the data behind the service map.

1. Find out why the Service `hubble-ui` has no working endpoint and repair it. The Deployment `hubble-ui` must be ready.
2. Create the ConfigMap `ui-report` in `starfleet` with the key `dropped-edge` (the edge the service map would show as dropped, written `source->destination` with `namespace/pod` names) and the key `namespaces` (the namespaces that appear in the map, sorted and separated by commas).

Do not change the `probe-ingress` policy.

`kubectl` already points at the cluster as the cluster administrator.
