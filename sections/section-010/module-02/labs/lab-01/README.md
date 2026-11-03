---
estimated_duration: 25m
---

# Lab: Enable Hubble Drop Metrics And Resize The Flow Buffer

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-055-lab-010-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-config-keys-set.sh` | cilium-config enables drop and flow metrics on port 9965 and a buffer of 8191 |
| `validate-agent-running-new-buffer.sh` | The agent runs with a flow buffer of 8191 flows |
| `validate-drop-metric-exposed.sh` | The agent exposes hubble_drop_total with the policy-denied reason |
