# Some general information about Kubernetes

When using local Kubernetes such as minikube you can't expose services through LoadBalancer as in a cloud provider. So you have to use NodePorts instead. https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending. ClusterIP services on the other hand are only accessible inside the cluster, so keep that in mind.

You can create generic secrets with `kubectl create secret generic my-postgres-secret --from-literal user=admin --from-literal password=asdfasdf`.

And then fetch them and decode them using `kubectl get secret my-postgres-secret -o yaml | grep password | sed -n '1p' | awk '{print $2}' | base64 --decode`.

You can run `exec` inside containers/pods just like in Docker. Find a pod you'd like to inspect with `kubectl get pods` and then run the command you'd like with eg. `kubectl exec my-postgres-deployment-6d4d946655-9p8pn $(echo env)`. Use `kubectl exec -it my-postgres-deployment-6d4d946655-9p8pn bash` for interactive bash session.

To see logs of a pod first find the nam of the pod with `kubectl get pods` and then `kubectl logs migration-f6xts-cc54p`.

You can create resources with template file/folder as an argument: `kubectl create -f kubernetes-templates/my-postgres/` but it's more recommended to use `apply` since it does both creation/updating. Also you can delete resources with templates using eg. `kubectl delete -f kubernetes-templates/my-postgres/`.

`kubectl create secret tls tls-secret --cert=localhost.crt --key=localhost.key`
`kubectl create secret generic tls-dhparam --from-file=dhparam4096.pem`

`kubectl create secret tls tls-certificate --key <key-file>.key --cert <certificate-file>.crt`
`kubectl create secret generic tls-dhparam --from-file=<dhparam-file>.pem`

Get easily the address of a service:
`minikube service my-node-bootstrap-svc`

You can watch resources with `-w` option:
`kubectl get pods -w`

## Mounting local volumes to k8s

Very often when running k8s locally, you want to persist your files you download or move to the cluster. This way when you're stopping your minikube and restarting, again, they won't disappear into the cyber-hell.

To do this what I do is first create a persitentVolume and persistentVolumeClaim as independent deployment. For example I might use this setup called eg. `my-spark-pvc.yml`:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-spark-pv
  labels:
    type: local
    project: my-spark-cluster
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-spark-pvc
  labels:
    project: my-spark-cluster
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

**BUT** there is one thing missing here. This works fine and dandy if all we're doing is relaunching the same Helm chart / cluster but once you restart your minikube, poof all gone!

So we'll have to persist the volume to our own filesystem, here's a one guide that I found: https://stackoverflow.com/questions/48534980/mount-local-directory-into-pod-in-minikube

I can't be bothered with passing mount-flags to minikube that I'll forget anyway after deleting & restarting it to change the RAM/CPU limits. Instead I'd create a folder to path `~/k8s-mount` and change the hostPath of the YAML according to this table https://kubernetes.io/docs/setup/minikube/#mounted-host-folders. So in macOS the hosted folder is `/Users/`:
```
  hostPath:
    path: /Users/teemu/k8s-mount/spark-data
```

And that's it! Now you'll be able to persist the files even over cluster shutdowns. Makes life much easier when you don't have to download the same 1GB file over and over again. :)