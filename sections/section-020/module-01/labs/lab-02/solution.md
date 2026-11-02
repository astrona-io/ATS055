---
draft: true
exam_objectives:
- Enabling Layer 7 Protocol Visibility
---
# Record A Real HTTP Flow From Hubble Relay Solution

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-055-lab-020-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-055-lab-020-01-02" || exit 1
node_name="astro-ats-055-lab-020-01-02-control-plane"
worker_name="astro-ats-055-lab-020-01-02-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Apply the HTTP policy, generate GET /public and record an actual successful response flow. Use the local Hubble CLI and a temporary loopback-only port-forward. Store the complete Flow object under flow in the evidence report; the grader checks it still exists in the two-minute Relay window. Observe both L7 metadata and policy verdicts. Refresh the evidence before submitting if the window has expired.

Save this as `ciliumnetworkpolicy-allow-shuttle.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-shuttle
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: starfleet
    toPorts:
    - ports:
      - port: '8080'
        protocol: TCP
      rules:
        http:
        - method: GET
          path: /public
```

Save this as `record-flow.py`:

```python
import json,subprocess,time,sys,tempfile,os

def call(*args):
 r=subprocess.run(list(args),text=True,capture_output=True,timeout=20)
 assert r.returncode==0, 'Observation command failed: '+args[0]
 return r.stdout.strip()
def obj(kind,name,ns='starfleet'):
 return json.loads(call('kubectl',*(['-n',ns] if ns else []),'get',kind,name,'-o','json'))
def api(path):
 script='import urllib.request; print(urllib.request.urlopen('+repr('http://prometheus:9090'+path)+',timeout=8).read().decode())'
 return json.loads(call('kubectl','-n','starfleet','exec','shuttle','--','python','-c',script))
def save(data):
 resource={'apiVersion':'v1','kind':'ConfigMap','metadata':{'name':'evidence','namespace':'starfleet'},'data':{'report.json':json.dumps(data,sort_keys=True)}}
 with tempfile.NamedTemporaryFile(mode='w',suffix='.json',delete=False) as f:json.dump(resource,f);path=f.name
 try:call('kubectl','apply','-f',path)
 finally:os.unlink(path)

def observe():
 import socket
 with socket.socket() as socket_handle:
  socket_handle.bind(('127.0.0.1',0));port=socket_handle.getsockname()[1]
 process=subprocess.Popen(['kubectl','-n','kube-system','port-forward','--address=127.0.0.1','svc/hubble-relay',str(port)+':80'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 try:
  for attempt in range(40):
   try:
    with socket.create_connection(('127.0.0.1',port),timeout=0.25):break
   except OSError:
    assert process.poll() is None, 'Relay port-forward stopped'
    time.sleep(0.25)
  else:raise AssertionError('Relay port-forward did not become ready')
  text=call('hubble','observe','--server','127.0.0.1:'+str(port),'--since','2m','--from-pod','starfleet/shuttle','--protocol','http','--output','json')
  decoder=json.JSONDecoder();flows=[]
  while text.strip():
   message,index=decoder.raw_decode(text.lstrip());text=text.lstrip()[index:]
   if 'flow' in message:flows.append(message['flow'])
  return flows
 finally:
  process.terminate()
  try:process.wait(timeout=5)
  except subprocess.TimeoutExpired:process.kill();process.wait(timeout=5)
def allowed_response(flow):
 http=flow.get('l7',{}).get('http',{})
 return http.get('url','').endswith('/public') and http.get('code')==200

assert call('kubectl','config','current-context')=='kind-astro-ats-055-lab-020-01-02'
flow=next((f for f in observe() if allowed_response(f)),None)
assert flow, 'A successful public HTTP response is absent from Hubble'
save({'flow':flow})
```

Apply the scoped correction:

```sh
kubectl apply -f ciliumnetworkpolicy-allow-shuttle.yaml
kubectl -n starfleet exec shuttle -- python -c 'import urllib.request; print(urllib.request.urlopen('"'"'http://probe:8080/public'"'"',timeout=4).read().decode())'
sleep 3
python3 record-flow.py
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl -n starfleet exec shuttle -- python -c 'import urllib.request; print(urllib.request.urlopen('"'"'http://probe:8080/public'"'"',timeout=4).read().decode())'
kubectl -n starfleet exec shuttle -- python -c 'import urllib.request; print(urllib.request.urlopen('"'"'http://probe:8080/private'"'"',timeout=4).read().decode())'
```

Observe an HTTP response through Relay and verify it against the live flow window. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.

After recording your result, remove the independent lab with `astrona destroy ats-055-lab-020-01-02`.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
