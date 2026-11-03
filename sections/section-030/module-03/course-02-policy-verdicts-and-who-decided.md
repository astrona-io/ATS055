# Policy Verdicts And Who Decided

A drop reason of `POLICY_DENIED` says that a policy refused the traffic, but it does not say which policy or which side. In a cluster with many policies, you need to know which endpoint enforced the decision and in which direction. Hubble provides policy verdict events for this. This part explains them and how to use them to make a precise fix.

## Ingress and egress decisions

Cilium applies policy at the endpoint. When a pod sends traffic, the policy of the sender applies to egress. When the traffic arrives, the policy of the receiver applies to ingress. A packet must pass both. A pod that has no egress policy allows all egress. A pod that has an ingress policy allows only what the policy lists.

A drop on ingress of the `probe` means that the `probe` is selected by an ingress policy and none of its rules allow the sender. A drop on egress of the client means that the client has an egress policy that lacks a rule for the destination. The direction tells you which policy to open.

## Policy verdict events

A policy verdict event is a flow that the datapath emits when it makes a policy decision for a new connection. It exists for allowed and for denied connections, so you can also see why something works. Select these events with `--type policy-verdict`:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --type policy-verdict --last 10
```

Each line shows the verdict and the direction. In JSON, the field `traffic_direction` is `INGRESS` or `EGRESS`, the field `policy_match_type` says which kind of rule matched, and the field `event_type` is a policy verdict. The match type names values such as a rule that matched on L3 and L4, a rule that allows all traffic, or no match, which means that traffic was denied by default.

To see the denied connections only, add the verdict:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --type policy-verdict --verdict DROPPED --last 10 -o json
```

Read the `destination.labels` and the `traffic_direction`. For the `probe`, they show that the decision applied at ingress of a pod with the label `k8s:app=probe`. Now you know which policy to open: the one whose `endpointSelector` selects that label.

## Find the policy

List the policies of the namespace and read the one whose selector matches the label:

```sh
kubectl -n starfleet get ciliumnetworkpolicy
kubectl -n starfleet get ciliumnetworkpolicy probe-ingress -o yaml
```

Compare the rules with the labels of the sender, which you read from the drop flow. The sender in the flow has labels such as `k8s:app=rogue` and `k8s:io.kubernetes.pod.namespace=outpost`. A rule that selects only `app=shuttle` does not match. The fix is to add a rule for the sender, with the narrowest selector that still describes the pods that should be allowed.

## Check the fix

After the change, repeat the request and the same filter. A forwarded policy verdict for the pair, with a match type for your new rule, proves that the policy now allows the connection. Also check that the pods that must stay refused are still dropped. A fix that opens too much is as wrong as no fix.

You now know how to move from "denied" to "this rule on this endpoint". DNS is a common source of failures that look like network problems, and the next part applies the method to it.

## Common pitfalls

> [!WARNING]
> Policy verdict events appear for new connections, so a long-lived connection can show no new event. The namespace label is part of a selector: a rule for `app=rogue` without the namespace matches only the namespace of the policy. A fix that allows a whole namespace gives access to pods that you did not review. Several policies on one endpoint add up, so a rule can come from a policy you did not open.
