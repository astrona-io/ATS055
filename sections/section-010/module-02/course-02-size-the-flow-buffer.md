# Size The Flow Buffer

Hubble keeps flows in memory, so the time you can look back depends on the size of the buffer and on how fast new flows arrive. On a busy node, a small buffer holds only a few seconds of history. An incident that you investigate ten minutes later has then already left the buffer. This part explains the ring buffer, how to read its fill level, how to change its size and what a restart does to the flows.

## The ring buffer

The Hubble server of each agent stores flows in a ring buffer. It has a fixed number of slots. Each new flow takes the next slot, and when the last slot is used, the next flow overwrites the oldest one. The buffer therefore always holds the most recent flows, up to its capacity, and nothing older.

The capacity is set by the key `hubble-event-buffer-capacity` in the `cilium-config` ConfigMap. With Helm, the matching value is `hubble.eventBufferCapacity`. The value must have the form 2^n - 1: that is, 1, 3, 7, 15 and so on up to 65535. The chart default is 4095, which means a capacity of 4095 flows per node. Other valid values include 8191, 16383, 32767 and 65535. A value that is not of this form is not valid.

The reason for the form is how the buffer is implemented: it uses a mask on a counter to find the next slot, and that works only when the number of slots is a power of two. Because of this, you pick a valid value and do not choose an arbitrary number.

## How long do the flows last

The time that a buffer covers is the capacity divided by the flow rate. If a node produces 100 flows per second and the capacity is 4095, the buffer covers about 41 seconds. If the capacity is 65535, it covers about 655 seconds. The numbers are only an illustration of the division. The real rate of your node is shown by `hubble status` in the line `Flows/s`.

Check the fill level and the rate on the node:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble status
```

The line `Current/Max Flows` shows how many flows the buffer holds now and its capacity, with a percentage. When the buffer is full, the percentage is close to 100, and every new flow pushes an old one out. A full buffer is normal on a busy node. It is a reason to resize only if the look-back time is too short for your needs.

A larger buffer costs memory in the agent pod. Each stored flow takes space, and a capacity of 65535 holds sixteen times as many flows as 4095. You set the buffer size to match the look-back time you need and the memory the node can spare.

## Change the capacity

Patch the ConfigMap with a new value. The value is a string in the ConfigMap, even though it is a number:

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-event-buffer-capacity":"8191"}}'
```

The running agent still uses the old size. Restart the DaemonSet and wait for the rollout:

```sh
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=180s
```

Then read the status again. The agent pod is new, so the Hubble server inside it is new:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble status
```

`Max Flows` now shows the new capacity. The `Current Flows` count starts low, because the new buffer is empty, and it grows as the node produces events.

If you give an invalid value such as 10000, the agent cannot use it. Depending on the version, the agent either fails to start the Hubble server or falls back to a valid size. In both cases, read the agent log to find out:

```sh
kubectl -n kube-system logs ds/cilium -c cilium-agent --tail=50 | grep -i hubble
```

The log lines with `hubble` show whether the Hubble server started and with which settings.

## What a restart removes

The ring buffer lives in the memory of the agent process. When the agent restarts, the buffer is empty. Flows that you wanted to look at are gone after the restart, even if the new capacity is larger. This is the most important side effect of a buffer change: you cannot enlarge the buffer to recover flows that already left it, or that were in the old buffer when the pod stopped.

The metrics counters also restart from zero. A restart is therefore not neutral for observation. Plan the change for a time when you do not need the old flows, or export what you need before. If you need history beyond the buffer, export the flows to external storage, which Hubble supports through flow exporters, or rely on metrics for long-term trends.

## Restarts and traffic

A restart of the agent does not stop the traffic of pods on the node. The eBPF programs that the agent loaded stay in the kernel while the agent is down, so existing connections and the policy rules continue to work. New pods that start during the restart wait until the agent is back, because the agent sets up their endpoints. The restart is a small operational risk and not an outage, but you should not do it casually on a production node. A rolling restart through the DaemonSet updates one node at a time, so the rest of the cluster keeps its flows.

## A worked example of sizing

Take a node where `hubble status` shows a rate of 250 flows per second and a buffer capacity of 4095. Divide: 4095 divided by 250 is about 16 seconds. The team investigates incidents about five minutes after an alert, which is 300 seconds. At 250 flows per second, 300 seconds is 75000 flows. The largest valid capacity is 65535, which covers about 262 seconds at that rate. Even the largest buffer does not cover five minutes here. The conclusion is that the buffer alone cannot meet the requirement, and the team must reduce the flow rate or export flows.

The rate depends on the traffic and on the number of events that each connection creates. A node that runs many short connections produces more flows than one with a few long connections. The rate also rises when layer 7 visibility is on, because each request adds flows. After you enable more visibility, read the rate again and recompute the look-back time.

## Reducing and exporting

Two other tools complement the buffer. First, you can reduce what Hubble records. Hubble has filters for the flows it stores and exports, so that events nobody reads, such as the traffic of system namespaces, do not use buffer slots. Second, you can export flows to a file. The Hubble server can write flows to a file in JSON, and a log collector can ship the file to external storage. That storage has no capacity limit of the ring buffer, so the history lasts as long as you keep the files.

These options need more configuration than a buffer size, and they are outside the scope of this part. They matter because they answer the case in which the buffer cannot be large enough.

## Choosing a size

Use the data on your node. Read `Flows/s`, decide how many seconds or minutes you need to look back, multiply, and round up to the next valid value. Then check the memory use of the agent pod after the change. If the need is longer than the largest valid value gives, a bigger buffer is the wrong tool; use metrics for trends and an exporter for stored flows.

You now know what limits the history that Hubble gives you, how to read the limit and how to change it. The last open point is that every change in this module needs a restart, and a restart empties the evidence, so you read what you need before you apply it.

## Common pitfalls

> [!WARNING]
> The capacity must be 2^n - 1; 8000 or 10000 are not valid. Changing the ConfigMap alone does nothing until the agent restarts. A restart empties the buffer, so read the flows you need first. A larger buffer does not bring back flows that are already gone. A full buffer is normal; it is a problem only when the look-back time is too short.
