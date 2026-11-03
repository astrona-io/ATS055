---
estimated_duration: 25m
---

# Lab: Count HTTP Requests With Hubble Metrics

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-055-lab-020-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-metrics-keys-set.sh` | cilium-config enables httpV2 metrics on port 9965 |
| `validate-http-metric-exposed.sh` | The agent exposes hubble_http_requests_total after requests from shuttle |
| `validate-policy-unchanged.sh` | The probe policy keeps its GET /get rule and its single source |
