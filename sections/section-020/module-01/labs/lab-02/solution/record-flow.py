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
