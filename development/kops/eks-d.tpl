apiVersion: kops.k8s.io/v1alpha2
kind: Cluster
metadata:
  name: {{ .clusterName }}
spec:
  api:
    dns: {}
  authorization:
    rbac: {}
  channel: stable
  {{if .ipv6}}
  cloudControllerManager: {}
  {{end}}
  cloudProvider: aws
  configBase: {{ .configBase }}
  containerRuntime: containerd
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
  externalPolicies:
    node:
    - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
    master:
    - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
    bastion:
    - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
  iam:
    allowContainerRegistry: true
    legacy: false
  kubernetesApiAccess:
  - 0.0.0.0/0
  {{if .ipv6}}
  - ::/0
  {{end}}
  kubernetesVersion: {{ .kubernetesVersion }}
  masterPublicName: api.{{ .clusterName }}
  networkCIDR: 172.20.0.0/16
  networking:
    cilium:
      chainingMode: portmap
  {{if .ipv6}}
  nonMasqueradeCIDR: ::/0
  {{else}}
    nonMasqueradeCIDR: 100.64.0.0/10
  {{end}}
  sshAccess:
  - 0.0.0.0/0
  {{if .ipv6}}
  - ::/0
  {{end}}
  subnets:
  - cidr: 172.20.32.0/19
    {{if .ipv6}}
    ipv6CIDR: /64#0
    {{end}}
    name: {{.awsRegion}}a
    type: Public
    zone: {{.awsRegion}}a
  - cidr: 172.20.64.0/19
    {{if .ipv6}}
    ipv6CIDR: /64#1
    {{end}}
    name: {{.awsRegion}}b
    type: Public
    zone: {{.awsRegion}}b
  - cidr: 172.20.96.0/19
    {{if .ipv6}}
    ipv6CIDR: /64#2
    {{end}}
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
  metricsServer:
    enabled: true
    insecure: true
    image: {{ .metrics_server.repository }}:{{ .metrics_server.tag }}
  authentication:
    aws:
      image: {{ .awsiamauth.repository }}:{{ .awsiamauth.tag }}
  kubeDNS:
    provider: CoreDNS
    coreDNSImage: {{ .coredns.repository }}:{{ .coredns.tag }}
  masterKubelet:
    podInfraContainerImage: {{ .pause.repository }}:{{ .pause.tag }}
  kubelet:
    podInfraContainerImage: {{ .pause.repository }}:{{ .pause.tag }}
    anonymousAuth: false
    # for 1.19 and above webhook auth is the default mode
    authorizationMode: Webhook
    authenticationTokenWebhook: true

---

apiVersion: kops.k8s.io/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{.clusterName}}
  name: control-plane-{{.awsRegion}}a
spec:
  {{- if .controlPlaneInstanceProfileArn }}
  iam:
    profile: {{ .controlPlaneInstanceProfileArn }}
  {{- end }}
  image: 099720109477/ubuntu/images/hvm-ssd/ubuntu-focal-20.04-{{ .architecture }}-server-20201026
  machineType: {{ .instanceType }}
  maxSize: 1
  minSize: 1
  nodeLabels:
    kops.k8s.io/instancegroup: control-plane-{{.awsRegion}}a
  role: Master
  subnets:
  - {{.awsRegion}}a
  additionalUserData:
  - name: ssm-install.sh
    type: text/x-shellscript
    content: |
      #!/bin/sh
      sudo snap install amazon-ssm-agent --classic
      sudo snap start amazon-ssm-agent

---

apiVersion: kops.k8s.io/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{.clusterName}}
  name: nodes
spec:
  {{- if .nodeInstanceProfileArn }}
  iam:
    profile: {{ .nodeInstanceProfileArn }}
  {{- end }}
  image: 099720109477/ubuntu/images/hvm-ssd/ubuntu-focal-20.04-{{ .architecture }}-server-20201026
  machineType: {{ .instanceType }}
  maxSize: 3
  minSize: 3
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  role: Node
  subnets:
  - {{.awsRegion}}a
  - {{.awsRegion}}b
  - {{.awsRegion}}c
  additionalUserData:
  - name: ssm-install.sh
    type: text/x-shellscript
    content: |
      #!/bin/sh
      sudo snap install amazon-ssm-agent --classic
      sudo snap start amazon-ssm-agent
