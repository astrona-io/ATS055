---
estimated_duration: 25m
---

# Lab: Repair The Hubble UI

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-055-lab-030-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-ui-has-endpoints.sh` | The hubble-ui Deployment is ready and the Service has a ready endpoint |
| `validate-ui-answers.sh` | The Hubble UI answers an HTTP request through the Service |
| `validate-ui-report-correct.sh` | ui-report lists the dropped edge and the namespaces of the map |
