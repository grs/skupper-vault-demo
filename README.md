# skupper-vault-demo

Demo of proposed vault integration for automating network setup with skupper

## Overview

This demo shows how vault integration with the skupper controller can
automate the setup of networks in a declarative way across kubernetes
clusters.

The demo uses three different clusters - one private (cluster1), two
public (cluster2 and cluster3) - and creates two distinct skupper
networks each including a praticular namespace on one of these three
clusters. The approach is of course more general.

## Setup

### kubernetes clusters

The example invocations here assume kubeconfig files for the three
clusters are created as cluster1.kubeconfig, cluster2.kubeconfig and
cluster3.kubconfig.

### Setup & configure vault

The demo assumes that vault is setup and reachable from all three
clusters.

I used the vault helm chart and installed it on one of the public
clusters used in the demo (cluster1) with the following options:

```
helm install vault hashicorp/vault --namespace vault --version 0.25.0 --set "server.dev.enabled=true" --set "injector.enabled=false" --set "global.openshift=true" --set "server.route.enabled=true" --set "server.image.repository=hashicorp/vault" --set "server.image.tag=1.14.8-ubi"
```

and then exposed that:

```
oc expose service vault
```

Required configuration:

* Enable kubernetes auth mode
* Enable approle auth mode
* Create a policy for skupper controllers (see ./cluster-controller-role.hcl)
* Create role for skupper controllers
* Configure kubernetes auth on cluster2

### Deploy controller using kubernetes auth on cluster2

```
kubectl --kubeconfig ./cluster2.kubeconfig apply -f cluster2/controller.yaml
```

### Deploy controllers using approle auth on cluster1 and cluster3

```
for c in cluster1 cluster3; do cat $c/controller.yaml | VAULT_SECRET_ID=$(vault write -force auth/approle/role/skuppercc/secret-id | awk '/secret_id /{print $2}') envsubst | kubectl --kubeconfig $c.kubeconfig apply -f - ; done
```

### Create labelled namespaces on each cluster

```
for c in cluster1 cluster2 cluster3; do kubectl --kubeconfig $c.kubeconfig apply -f $c/namespaces.yaml; done
```
