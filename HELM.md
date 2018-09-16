# Using Helm

Helm is this package manager for Kubernetes, maintained by Microsoft https://docs.helm.sh/

It's pretty convenient to install k8s clusters and has already a nice list of curated versions so that you don't have to build everything from scratch: https://github.com/helm/charts

However running these Helm charts as they are called locally might cause some pain due to some unforeseen configuration problems.

For example say you want to install Hadoop from the Helm's official charts, this is the shortest way to do it:
```bash
helm install stable/hadoop
```

In no time there should be a Hadoop cluster running in your computer! Pretty neat.

But however if you're seeing from your dashboard errors such as `Insufficient cpu.` or `Insufficient memory.` you got yourself into a pickle. Well luckily it's not a huge mess to fix but if you're running your k8s with minikube you're going to have to increase it's cpu/memory limits with quite a bit of force [link](https://github.com/kubernetes/minikube/issues/567). Uhh well once you got that sorted, basically you should increase your limits to at least 4GB and two cores (`minikube --memory 4096 --cpus 2 start`) we're going to have to tweak the chart's configuration variables.

As you might see from the [Hadoop's README](https://github.com/helm/charts/tree/master/stable/hadoop) it defaults to 2 nodes with 2GB RAM each. With that `4096` MBs you're going to be little short as other k8s stuff need that RAM too. So we need to decrease the replica amount to 2 and give its required resources. But why can't I just decrease the node size to say 1GB you ask? Well... as things stand out and I'm not 100% sure but that 2GB is hard-coded as the node-size and you can't decrease it below that using at least this Helm chart. Maybe if you forked and tweaked it by yourself. Quite inconvenience in my opinion but I guess 2GB is such paltry amount for a big-data cluster that you'd never want to go below than that. Who knows.

Anyway if you have already installed that Hadoop chart you could instead of deleting the old one just upgrade it with your new settings:
```bash
helm upgrade \
   --set yarn.nodeManager.resources.limits.memory=4096Mi \
   --set yarn.nodeManager.replicas=1 \
   <your hadoop helm release name>
   stable/hadoop
```
use `helm list` to see what's your release name.

And that's should do it! Now you have a running Hadoop cluster, whooppee. I wrote some instructions how to run WordCount on it if [you're interested](https://gist.github.com/TeemuKoivisto/5632fabee4915dc63055e8e544247f60). Possibly not the smartest way of installing Hadoop on your local computer but oh well. It was nice practise at least.

Instead of giving the values directly to the helm you can use a `.yml` file instead:
```yaml
yarn:
  nodeManager:
    resources:
      limits:
        memory: 4096Mi
    replicas: 1
```
and then: `helm upgrade -f <your release> stable/hadoop`. Cool!