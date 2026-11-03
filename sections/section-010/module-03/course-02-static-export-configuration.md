# Static Export Configuration

The static exporter is the simplest way to get flows into a file. You choose a file path and the agent starts writing. This part sets the file path, shows the Helm values that do the same, and reads the result.

## The settings

With Helm, the static exporter uses these values:

| Helm value | Meaning |
| --- | --- |
| `hubble.export.static.enabled` | Turns the static exporter on |
| `hubble.export.static.filePath` | The file in the agent container, default `/var/run/cilium/hubble/events.log` |
| `hubble.export.fileMaxSizeMb` | The size at which the file is rotated, default 10 |
| `hubble.export.fileMaxBackups` | How many rotated files are kept, default 5 |
| `hubble.export.static.allowList` | A list of filters; a flow must match one to be written |
| `hubble.export.static.denyList` | A list of filters; a matching flow is not written |
| `hubble.export.static.fieldMask` | The flow fields to keep |

The chart turns these into keys of the `cilium-config` ConfigMap. The keys are `hubble-export-file-path`, `hubble-export-file-max-size-mb`, `hubble-export-file-max-backups`, `hubble-export-allowlist`, `hubble-export-denylist` and `hubble-export-fieldmask`. The file path is the key that switches the exporter on.

## Turn it on

The next command sets only the file path in the ConfigMap. Then the agents restart, because they read the key at start:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-export-file-path":"/var/run/cilium/hubble/events.log"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

Read the last lines of the file:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- tail -n 2 /var/run/cilium/hubble/events.log
```

You see two lines of JSON. Each line has the key `flow` with the fields that you know from `hubble observe -o json`, for example `verdict`, `source` and `destination`, and also the keys `node_name` and `time`.

Because the playground has a client that sends a request every 5 seconds, new lines keep arriving. Count the lines twice, a few seconds apart:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- wc -l /var/run/cilium/hubble/events.log
```

The number grows. Without a filter, every flow of the node goes to the file, including forwarded and dropped flows.

## Where the restart matters

The agent opens the file at start and appends to it. A restart does not delete the file, so lines from before the restart stay. The file exists inside the agent container. If the agent pod is deleted, a file on the container file system can be lost unless the directory is on a volume that survives. The Helm chart mounts the Hubble run directory from the node, so the file survives a pod restart, but you must confirm this for your installation.

You can now start an export, but it writes everything. The next part reduces the amount of data.

## Common pitfalls

> [!WARNING]
> Setting the file path in the ConfigMap without restarting the agents changes nothing. A path outside the mounted directory can fail because the agent cannot create the file. The export keys are separate from the metrics keys, so enabling one does not enable the other. A file path in a Helm upgrade without `hubble.export.static.enabled=true` may be ignored.
