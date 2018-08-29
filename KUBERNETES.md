# Some general information about Kubernetes


When using local kubernetes such as minikube you can't expose services through LoadBalancer as in a cloud provider. So you have to use NodePorts instead. https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending


You can create secrets with `kubectl create secret `

And then fetch them and decode them using `kubectl get secret my-pg-password -o yaml | grep password | sed -n '1p' | awk '{print $2}' | base64 --decode`