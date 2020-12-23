# EKS Distro kOps Cluster

Follow these instructions to create an EKS-D Kubernetes cluster using
kOps.  Refer to the [kops documentation](https://kops.sigs.k8s.io/getting_started/aws/)
for full instructions.  Most of these commands require that you have
`KOPS_STATE_STORE` and `KOPS_CLUSTER_NAME` set and exported.

## kOps Cluster Create

### 1. Clone the eks-distro Repository
The easiest way to access our sample kOps scripts would be to clone the
repository and cd to the `kops` directory:
```bash
git clone https://github.com/aws/eks-distro.git
cd eks-distro/development/kops 
```

### 2. Create the Cluster Configuration
You will need to set and export `KOPS_STATE_STORE` to the s3 bucket to use for
your kOps state and `KOPS_CLUSTER_NAME` to a valid subdomain controlled by Route53.
If your kOps state store does not exist, this script will create it. It will
also generate the cluster configuration:
```bash
export KOPS_STATE_STORE=s3://kops-state-store
export KOPS_CLUSTER_NAME=clustername.example.com
./create_configuration.sh 
```

### 3. Create the Cluster
Once the cluster configuration has been created succcessfully, create the
EKS-D cluster:
```bash
./create_cluster.sh 
```

### 4. Wait for the Cluster
It may take a while for the cluster. You can use the `cluster_waith.sh`
script to wait for the cluster to be ready. Once the cluster is ready this
script will add the AWS IAM authenticator.
```bash
./cluster_wait.sh
```
When the script completes, your cluster is ready to use.

## Verify Your Cluster is Running EKS-D

You can verify the pods in your cluster are using the EKS Distro images by running
the following command:
```bash
kubectl get po --all-namespaces -o json | jq -r .items[].spec.containers[].image | sort -u
```

## kOps Cluster Delete

To tear down the cluster, run:
```bash
./delete_cluster.sh
```
