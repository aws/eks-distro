apiVersion: kops.k8s.io/v1alpha2
kind: Cluster
metadata:
  creationTimestamp: null
  name: {{ .clusterName }}
spec:
  api:
    dns: {}
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: {{ .configBase }}
  containerRuntime: docker
  etcdClusters:
  - cpuRequest: 200m
    etcdMembers:
    - instanceGroup: control-plane-{{.awsRegion}}a
      name: a
    memoryRequest: 100Mi
    name: main
  - cpuRequest: 100m
    etcdMembers:
    - instanceGroup: control-plane-{{.awsRegion}}a
      name: a
    memoryRequest: 100Mi
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  kubelet:
    anonymousAuth: false
  kubernetesApiAccess:
  - 0.0.0.0/0
  kubernetesVersion: {{ .kubernetesVersion }}
  masterPublicName: api.{{ .clusterName }}
  networkCIDR: 172.20.0.0/16
  networking:
    kubenet: {}
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  - 0.0.0.0/0
  subnets:
  - cidr: 172.20.32.0/19
    name: {{.awsRegion}}a
    type: Public
    zone: {{.awsRegion}}a
  - cidr: 172.20.64.0/19
    name: {{.awsRegion}}b
    type: Public
    zone: {{.awsRegion}}b
  - cidr: 172.20.96.0/19
    name: {{.awsRegion}}c
    type: Public
    zone: {{.awsRegion}}c
  topology:
    dns:
      type: Public
    masters: public
    nodes: public
  kubeAPIServer:
    image: {{ .kube_apiserver.repository }}:{{ .kube_apiserver.tag }}
  kubeControllerManager:
    image: {{ .kube_controller_manager.repository }}:{{ .kube_controller_manager.tag }}
  kubeScheduler:
    image: {{ .kube_scheduler.repository }}:{{ .kube_scheduler.tag }}
  kubeProxy:
    image: {{ .kube_proxy.repository }}:{{ .kube_proxy.tag }}
  # Metrics Server will be supported with kops 1.19
  metricsServer:
    enabled: true
    image: {{ .metrics_server.repository }}:{{ .metrics_server.tag }}
  authentication:
    aws:
      image: {{ .awsiamauth.repository }}:{{ .awsiamauth.tag }}
  kubeDNS:
    provider: CoreDNS
    coreDNSImage: {{ .coredns.repository }}:{{ .coredns.tag }}
    externalCoreFile: |
      .:53 {
          errors
          health {
            lameduck 5s
          }
          kubernetes cluster.local. in-addr.arpa ip6.arpa {
            pods insecure
            #upstream
            fallthrough in-addr.arpa ip6.arpa
          }
          prometheus :9153
          forward . /etc/resolv.conf
          loop
          cache 30
          loadbalance
          reload
      }
  masterKubelet:
    podInfraContainerImage: {{ .pause.repository }}:{{ .pause.tag }}
  # kubelet might already be defined, append the following config
  kubelet:
    podInfraContainerImage: {{ .pause.repository }}:{{ .pause.tag }}

---

apiVersion: kops.k8s.io/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: null
  labels:
    kops.k8s.io/cluster: {{.clusterName}}
  name: control-plane-{{.awsRegion}}a
spec:
  image: 099720109477/ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20201026
  machineType: t3.medium
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: control-plane-{{.awsRegion}}a
  role: Master
  subnets:
  - {{.awsRegion}}a

---

apiVersion: kops.k8s.io/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: null
  labels:
    kops.k8s.io/cluster: {{.clusterName}}
  name: nodes
spec:
  image: 099720109477/ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20201026
  machineType: t3.medium
  maxSize: 3
  minSize: 3
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  role: Node
  subnets:
  - {{.awsRegion}}a
  - {{.awsRegion}}b
  - {{.awsRegion}}c
