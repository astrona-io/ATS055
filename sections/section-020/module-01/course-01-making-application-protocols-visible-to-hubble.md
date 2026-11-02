---
draft: true
exam_objectives:
- Enabling Layer 7 Protocol Visibility
---
# Making Application Protocols Visible To Hubble

Layer 3 and Layer 4 flow context describes addresses, protocols and ports. Layer 7 visibility adds supported application-protocol information, such as HTTP methods, status or DNS context. It can make dependency failures easier to understand, but it requires the traffic and implementation to provide interpretable protocol evidence.

## Lower Layers Do Not Explain Every Operation

A TCP connection to a web service can carry many different requests. Addresses and ports show the transport relationship, but do not identify which path was requested or whether the application returned an error. Layer 7 observations can add that context where the selected feature supports it.

The feature is not universal application tracing. A flow record does not automatically contain every internal function, database operation or distributed span. Use the correct signal for the question and avoid treating additional HTTP fields as complete knowledge of the application's work.

## Visibility Needs A Processing Path

Selected Cilium policy or visibility arrangements can direct traffic through an application-aware path that produces supported protocol observations. Envoy can participate in this processing. Enabling Hubble alone does not imply that every connection is parsed at Layer 7 or that every protocol is supported.

Review the feature's documented configuration and prerequisites. A policy object with an application rule can be valid while its processing dependency is unavailable. Conversely, lower-layer flows can remain visible even when application details are absent. Determine which stage should have supplied the missing context.

## Encryption Changes What Is Available

An observer seeing encrypted payload bytes cannot simply read their HTTP path. The termination point and supported protocol handling determine whether application context is accessible. TLS passthrough, application termination and proxy termination provide different visibility boundaries.

Do not disable encryption merely to make a dashboard more detailed without a justified design decision. The desired observability and confidentiality requirements must be reconciled explicitly. Application telemetry can supply useful evidence without exposing every payload to the network observer.

## Observation Intent Can Affect Enforcement

A policy introduced for visibility can also select endpoints or constrain application operations. Default-deny controls and Layer 7 allow behavior have documented interactions. Disabling a default-deny transition is not a universal guarantee that a restricted Layer 7 rule will never drop traffic.

Suppose a policy observes DNS but inadvertently restricts other required behavior. Identify the selected direction, protocol rules and effective enforcement rather than conclude that Hubble itself broke forwarding. The observation component and the policy processing path have different responsibilities even when one configuration change enables both.

## Control Detail And Cost

Application attributes can reveal hostnames, paths or other operational information. Protect access and avoid collecting unnecessary confidential fields. Additional parsing and metrics can also have capacity costs. Define the observation question and retain the detail needed to answer it rather than assume maximum detail is always desirable.

A missing HTTP record can reflect unsupported protocol, encrypted context, absent redirection, filters or collection limits. Check those explanations in order before making a claim about traffic absence. Correlate available lower-layer and application evidence, preserving the meaning of each. The result should identify the observable boundary and its limits clearly.

## Common pitfalls

> [!WARNING]
> Layer 7 fields are not automatic for every flow. Encryption and processing prerequisites affect visibility, and a policy intended for observation can still change enforcement.
