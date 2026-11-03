# Question

Solve this question on: `terminal`

Two things are wrong at the same time. The Hubble UI cannot be opened, and the pod `rogue` in `outpost` is dropped when it calls the `probe`.

1. Repair the Hubble UI: the Deployment `hubble-ui` must be ready and the Service `hubble-ui` must have a ready endpoint.
2. Use `hubble observe` to find the dropped source, the destination and its port. Create the ConfigMap `cli-report` in `starfleet` with the keys `dropped-source`, `destination`, `destination-port` and `verdict`.
3. Create the ConfigMap `ui-report` in `starfleet` with the key `dropped-edge` (written `source->destination`) and the key `namespaces` (sorted, comma-separated).
4. Allow only `rogue` (label `app=rogue`, namespace `outpost`) to reach port 8080 of the `probe`. Keep `shuttle` allowed and `drifter` refused.

`kubectl` already points at the cluster as the cluster administrator.
