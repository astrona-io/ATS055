# Dynamic Export And Rotation

A single static file is enough for one purpose. Real clusters have several: one file for dropped flows for the security team, another for DNS flows for the network team. The dynamic exporter supports several files and applies changes without a restart. This part explains it and the rotation that protects the disk.

## Dynamic export

The dynamic exporter is enabled with the Helm value `hubble.export.dynamic.enabled=true`. It reads its list from a ConfigMap named `cilium-flowlog` in `kube-system`, which the chart creates from the value `hubble.export.dynamic.config.content`. Each entry has a name, a file path, an optional field mask and optional include and exclude filters. The include and exclude filters use the same JSON format as the allow and deny lists.

A configuration with two exports looks like this in the Helm values:

```yaml
hubble:
  export:
    dynamic:
      enabled: true
      config:
        enabled: true
        content:
        - name: dropped
          filePath: /var/run/cilium/hubble/dropped.log
          includeFilters:
          - verdict: [DROPPED]
        - name: dns
          filePath: /var/run/cilium/hubble/dns.log
          includeFilters:
          - protocol: [DNS]
```

The agent watches the `cilium-flowlog` ConfigMap. When you change it, the agent starts, changes or stops the exporters without a restart. That is the main advantage over the static mode. The dynamic mode can run next to the static mode.

## Rotation

An export file never stops growing by itself. The exporter rotates it. When the file reaches `hubble.export.fileMaxSizeMb` megabytes, the exporter renames it with a timestamp and starts a new file. It keeps at most `hubble.export.fileMaxBackups` old files and removes the rest. With the defaults of 10 megabytes and 5 backups, one export uses at most about 60 megabytes of disk.

A log collector must handle rotation. It must follow the file by name and read the rotated file to the end before it lets go. Most collectors support this, but a collector that is configured for a fixed file can miss lines at the moment of the rotation.

Look at the directory in the playground after some time:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- ls -l /var/run/cilium/hubble
```

You see the current file. After many flows, you also see rotated files with a time stamp in the name.

## Choosing a mode

Use the static mode for one export that does not change. Use the dynamic mode when several teams need different files, or when you need to start an export during an incident without restarting the agents. In both modes, set the rotation values so that the disk of the node is safe.

You now know how to move flows out of the ring buffer and how to keep the disk safe. The flows are no longer limited by the buffer, and the limit moves to your storage and filters.

## Common pitfalls

> [!WARNING]
> The rotation values are global to the exporters, so a small maximum size makes every file rotate quickly. A deleted backup cannot be recovered, so a collector that is down for a long time loses lines. Several dynamic exports multiply the disk use. A change to the `cilium-flowlog` ConfigMap with invalid JSON in a filter stops that export.
