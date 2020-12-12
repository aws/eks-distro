## Starting a Cluster

Before you start your cluster, you need to get several container images.
Container images can be accessed either from the public ECR registry or
built from scratch.

### EKS Distro Container Images

You can pull the images that make up the EKS Distro from the Public ECR Gallery,
and a [pull-all.sh shell
script](https://github.com/aws/eks-distro/blob/main/development/pull-all.sh) is
provided to demonstrate how to do this. You can also browse the [EKS Distro
Container Repository](https://gallery.ecr.aws/?searchTerm=eks-distro&verified=verified)

### Building Your Own Container Images
See the [Build Guide](build.md) for more information about building your own
container images.

## Run the kOps create cluster script

Run the create cluster script:
```bash
cd development/kops
./create_cluster.sh
```

Refer to the [kops documentation](https://kops.sigs.k8s.io/getting_started/aws/)
for full instructions.

When your DNS is available for your cluster you'll need to deploy the aws-iam-authenticator.yaml ConfigMap so the pods can schedule properly.
```bash
kubectl apply -f ./aws-iam-authenticator.yaml

# Delete the pods that were created before the ConfigMap existed
kubectl delete pod -n kube-system -l k8s-app=aws-iam-authenticator
```

You can verify the pods in your cluster are using the EKS Distro images by running
the following command:
```bash
kubectl get po --all-namespaces -o json | jq -r .items[].spec.containers[].image | sort -u
```

To tear down the cluster, run:
```bash
kops delete -f ./$CLUSTER_NAME.yaml --yes
```
