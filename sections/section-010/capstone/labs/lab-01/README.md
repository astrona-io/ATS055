---
estimated_duration: 45m
---

# Lab: Observe Dropped Traffic End To End

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-055-lab-010-cap
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-settings-applied.sh` | Drop and flow metrics on :9965 and a buffer of 16383 are active in the agent |
| `validate-drop-report-correct.sh` | drop-report names the right source, destination and port |
| `validate-drop-report-reason.sh` | drop-report gives the policy-denied reason |
| `validate-drop-metric-exposed.sh` | The agent exposes hubble_drop_total |
