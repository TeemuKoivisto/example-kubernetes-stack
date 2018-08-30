# Some general information about Kubernetes

When using local Kubernetes such as minikube you can't expose services through LoadBalancer as in a cloud provider. So you have to use NodePorts instead. https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending. ClusterIP services on the other hand are only accessible inside the cluster, so keep that in mind.

You can create generic secrets with `kubectl create secret generic my-postgres-secret --from-literal user=admin --from-literal password=asdfasdf`.

And then fetch them and decode them using `kubectl get secret my-postgres-secret -o yaml | grep password | sed -n '1p' | awk '{print $2}' | base64 --decode`.

You can run `exec` inside containers/pods just like in Docker. Find a pod you'd like to inspect with `kubectl get pods` and then run the command you'd like with eg. `kubectl exec my-postgres-deployment-6d4d946655-9p8pn $(echo env)`. Use `kubectl exec -it my-postgres-deployment-6d4d946655-9p8pn bash` for interactive bash session.

To see logs of a pod first find the nam of the pod with `kubectl get pods` and then `kubectl logs migration-f6xts-cc54p`.

You can create resources with template file/folder as an argument: `kubectl create -f kubernetes-templates/my-postgres/` but it's more recommended to use `apply` since it does both creation/updating. Also you can delete resources with templates using eg. `kubectl delete -f kubernetes-templates/my-postgres/`.