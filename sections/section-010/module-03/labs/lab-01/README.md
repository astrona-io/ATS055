---
estimated_duration: 25m
---

# Lab: Export Dropped Flows To A File

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-055-lab-010-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-export-keys-set.sh` | cilium-config sets the export file path and an allow list for dropped flows |
| `validate-export-has-drops.sh` | The export file in the agent pod contains dropped flows |
| `validate-export-only-drops.sh` | The export file holds no forwarded flows |
