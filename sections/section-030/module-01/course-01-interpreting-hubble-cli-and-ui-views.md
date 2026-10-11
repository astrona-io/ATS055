---
draft: true
exam_objectives:
- Know How to Use Hubble from the Command Line or the Hubble UI
---
# Interpreting Hubble CLI And UI Views

The Hubble CLI and UI are clients of the observation path. They help retrieve flow events and present service relationships, but their views depend on the selected endpoint, available servers, time selection and filters. Understanding those choices is more important than memorizing a screenshot or assuming every empty panel indicates a network outage.

## Select The Observation Scope

A client can use a local Hubble server or a Relay endpoint under the supported configuration. Local access shows the relevant node's observations, while Relay can aggregate reachable servers. The chosen access path needs permissions and connectivity. A client-side authentication or connection error does not establish that application packet forwarding failed.

The remote client's context also matters. An operator can accidentally inspect another cluster or an endpoint with incomplete aggregation. State the intended cluster and scope before interpreting the records. A successful client connection confirms access to that observation endpoint, not complete coverage of every workload.

## Filters Define The Displayed Population

Filters can narrow source, destination, namespace, protocol, verdict or other supported fields. Time selection distinguishes recent buffered observations from newly streamed events. A filter based on an old Pod address can miss its replacement, while a namespace filter can exclude a proxy or external destination involved in the path.

Use filters to test a specific hypothesis, then widen them deliberately if the expected record is absent. Widening a view changes the observed population; it does not change policy or create past records. Preserve the relationship between the selected record and the actual client request.

## Request And Reply Are Different Context

A connection can have request and reply observations with different directions and endpoints. Translation, proxies and routing can change the visible addresses at different points. A forwarded request without a visible reply can indicate a destination or return-path problem, but it can also reflect observation coverage.

Interpret the supported flow fields and verdict reason rather than expect every request to appear as one universally complete row. Application errors can occur after transport succeeds. A useful investigation pairs flow evidence with listener, Service and application observations.

## Service Maps Summarize Observed Relationships

The UI can build a service dependency map from observed flows. It helps identify active relationships and selected protocol context. It is not a complete specification of every dependency the application could use, nor a permanent inventory of every historical connection.

An edge can be absent because no relevant traffic occurred during the view, because filters excluded it or because observation was unavailable. An edge being present does not establish correct business authorization. Use the map as a visual index into evidence, not as an automatic security approval.

## Diagnose Client And Collection Failures

When the view is empty, check client access, selected scope, Relay connectivity, available servers, filters and retention. If those are sound, assess whether the traffic path generates the expected supported observations. Avoid changing endpoint policy simply to repair an unrelated UI access problem.

The CLI can provide a more focused record view while the UI highlights relationships, but both depend on the underlying observation contract. Protect their access because flow context can expose topology and sensitive operations. This reading course explains the decision process and client roles without requiring a live cluster or executed commands.

## Common pitfalls

> [!WARNING]
> An empty filtered view is not proof of no traffic. Service maps describe observed relationships, and client or Relay access failure can occur independently of application forwarding.
