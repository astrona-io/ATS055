---
estimated_duration: 25m
---

# Lab: Diagnose A Dropped Pod With Hubble

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-055-lab-030-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-cadet-reaches-probe.sh` | cadet in starfleet reaches the probe and shuttle still does |
| `validate-policy-verdict-forwarded.sh` | Hubble shows a forwarded policy verdict for cadet |
| `validate-others-still-denied.sh` | drifter and rogue in outpost are still refused |
