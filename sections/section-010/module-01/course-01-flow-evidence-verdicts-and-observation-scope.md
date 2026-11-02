---
draft: true
exam_objectives:
- Understand the Observability Capabilities of Hubble
---
# Flow Evidence, Verdicts And Observation Scope

Hubble provides observations of supported network behavior from Cilium. A flow record can include source and destination context, protocol information, direction and a verdict such as forwarded or dropped. These records help explain a connection path, but they are observations at particular points rather than a complete ledger of every application operation.

## Read The Available Context

Endpoint labels, addresses and security identities can connect a network record to a workload relationship. Protocol and port information describe the transport, while supported Layer 7 context can describe an application operation. The available fields depend on enabled features and the observed path.

A source name alone may not distinguish a replaced Pod from an earlier instance. Combine timing, endpoint identity and lifecycle context when correlating records. External peers can have different identity information from managed workloads, so do not assume every destination is represented by an authenticated application identity.

## Scope Depends On The Access Path

A Hubble server provides local observations from its Cilium environment. Relay aggregates records from reachable servers and exposes a broader view. If a server is unavailable to Relay, the aggregate can be incomplete even while some local records remain available. The UI and CLI then apply their own selection and presentation.

Identify whether the client is using one server or Relay. A query scoped to one node cannot establish that no matching flow occurred elsewhere. Likewise, an aggregate view does not automatically guarantee historical completeness across every node or cluster.

## Verdicts Are Scoped Evidence

A forwarded verdict indicates the relevant observed operation was forwarded under that context. It does not prove the destination application accepted the request, authenticated the user or returned a correct result. The process can reject the operation after the network path succeeds.

A dropped observation can help identify policy or datapath denial, but its reason and observation point matter. A client timeout can result from missing routing, policy filtering, an unavailable destination or application behavior. Use the flow's actual reason rather than label every timeout as a policy problem.

## Buffers And Collection Have Limits

Flow observation uses finite resources and retention. High traffic, event loss, filters and delayed retrieval can reduce the records available for investigation. Streaming new records and retrieving recent buffered records answer different time questions. A current empty view does not reconstruct all past traffic.

Metrics derived from flows can summarize behavior across time, but they do not retain every original event's detail. Logs and application records can provide complementary evidence. Protect access to flow data because names, addresses and application attributes may reveal sensitive topology or operations.

## Use Flows To Test A Hypothesis

Suppose checkout cannot reach a database. Select the relevant workload, destination and interval, then look for request and reply context and applicable verdicts. If the request is forwarded but no useful response appears, investigate the destination and return path. If policy denies it, inspect the effective selected relationship rather than disable all enforcement.

Confirm whether the observed path matches the client operation and whether a proxy or translation changes visible endpoints. Correlate the network evidence with Service selection, endpoint readiness and application logs. Each source narrows the hypothesis within its coverage; none should be overstated as complete application proof.

## Common pitfalls

> [!WARNING]
> Forwarded traffic is not a successful business operation. Local scope, finite buffers and filters can explain missing records, while Relay availability affects aggregate coverage separately from forwarding.
