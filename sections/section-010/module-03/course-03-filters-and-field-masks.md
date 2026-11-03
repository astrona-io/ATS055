# Filters And Field Masks

An export of all flows is large. Two controls reduce it. Filters decide which flows are written, and the field mask decides which fields of a flow are written. This part explains both, with the format of each.

## Filters use the flow filter format

An allow list and a deny list contain filters in the same JSON format that the Hubble API uses, so every field that you can filter with `hubble observe` is available. A filter is a JSON object. In the ConfigMap, the value is the JSON text. A flow is written when it matches at least one allow filter, or when no allow list exists. A flow that matches a deny filter is never written, even when it matches an allow filter.

An allow list for dropped flows is:

```json
{"verdict":["DROPPED"]}
```

Fields inside one filter object are combined with AND, and the values in one list are combined with OR. This filter selects dropped flows to the `starfleet` namespace:

```json
{"verdict":["DROPPED"],"destination_pod":["starfleet/"]}
```

The value `starfleet/` selects every pod in the namespace `starfleet`. Several filter objects in a list are combined with OR. Other keys that you will use are `source_pod`, `source_label`, `protocol`, `http_status_code` and `event_type`.

Set an allow list for dropped flows and restart the agents:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-export-allowlist":"{\"verdict\":[\"DROPPED\"]}"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

The file keeps the older lines from before the filter. New lines are only dropped flows. Check the newest lines:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- tail -n 3 /var/run/cilium/hubble/events.log
```

## The field mask

A flow record has many fields. A log search often needs only a few. The field mask is a list of field paths. The exporter keeps only those fields. With Helm, the value is a list such as `hubble.export.static.fieldMask={time,source.namespace,source.pod_name,destination.namespace,destination.pod_name,verdict,drop_reason_desc}`. The paths use the field names of the flow, with dots for nested objects.

A mask has a trade-off. The records are smaller and cheaper to store, but a field that is not in the mask is lost for good. You cannot add it later to old lines. Start with a generous mask and remove fields after you know what your searches use.

You can choose between the filters and the mask for different goals. A filter reduces the number of lines. A mask reduces the size of each line. Use the filter first, because a line that is not written costs nothing at all.

You now control what goes to the file. The last part deals with several files and with the growth of the file over time.

## Common pitfalls

> [!WARNING]
> A deny filter wins over an allow filter. The value inside the ConfigMap must be valid JSON, and a quote that is not escaped in the patch command breaks it. A filter field with a wrong name can match nothing and produce an empty file. A mask that is too narrow hides the field that an investigation needs later.
