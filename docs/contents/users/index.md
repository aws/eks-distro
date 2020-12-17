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

Follow these instructions to create a Kubernetes cluster with EKS-D.

### 1. Clone the eks-distro Repository
The easiest way to access our sample kOps scripts would be to clone the
repository and cd to the `kops` directory:
```bash
git clone https://github.com/aws/eks-distro.git
cd eks-distro/development/kops 
```

### 2. Create the Cluster Configuration
You will need to set and export `KOPS_STATE_STORE` to the s3 bucket to use for
your kOps state and `CLUSTER_NAME` to a valid subdomain controlled by Route53.
If your kOps state store does not exist, this script will create it. It will
also generate the cluster configuration:
```bash
export KOPS_STATE_STORE=s3://kops-state-store
export CLUSTER_NAME=clustername.example.com
./create_configuration.sh 
```

### 3. Create the Cluster
Once the cluster configuration has been created succcessfully, create the
EKS-D cluster:
```bash
./create_cluster.sh 
```

### 4. Wait for the Cluster
It may take a while for the cluster to come up and you may wish to use AWS
IAM authentication
```bash
kops validate cluster --wait 10m
kubectl apply -f ./aws-iam-authenticator.yaml
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
