module github.com/kubernetes-csi/external-snapshotter/v3

go 1.15

require (
	github.com/container-storage-interface/spec v1.2.0
	github.com/fsnotify/fsnotify v1.4.9
	github.com/golang/mock v1.4.3
	github.com/golang/protobuf v1.4.2
	github.com/google/gofuzz v1.1.0
	github.com/imdario/mergo v0.3.9 // indirect
	github.com/kubernetes-csi/csi-lib-utils v0.8.1
	github.com/kubernetes-csi/csi-test v2.0.0+incompatible
	github.com/kubernetes-csi/external-snapshotter/client/v3 v3.0.0
	github.com/prometheus/client_golang v1.7.1
	github.com/prometheus/client_model v0.2.0
	github.com/prometheus/common v0.10.0
	github.com/spf13/cobra v1.0.0
	google.golang.org/grpc v1.29.0
	k8s.io/api v0.19.16
	k8s.io/apimachinery v0.19.16
	k8s.io/client-go v0.19.16
	k8s.io/component-base v0.19.16
	k8s.io/klog v1.0.0
	k8s.io/klog/v2 v2.2.0
	k8s.io/kubernetes v1.19.16
)

replace (
	github.com/kubernetes-csi/external-snapshotter/client/v3 => ./client
	k8s.io/api => k8s.io/api v0.19.16
	k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.19.16
	k8s.io/apimachinery => k8s.io/apimachinery v0.19.16
	k8s.io/apiserver => k8s.io/apiserver v0.19.16
	k8s.io/cli-runtime => k8s.io/cli-runtime v0.19.16
	k8s.io/client-go => k8s.io/client-go v0.19.16
	k8s.io/cloud-provider => k8s.io/cloud-provider v0.19.16
	k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.19.16
	k8s.io/code-generator => k8s.io/code-generator v0.19.16
	k8s.io/component-base => k8s.io/component-base v0.19.16
	k8s.io/cri-api => k8s.io/cri-api v0.19.16
	k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.19.16
	k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.19.16
	k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.19.16
	k8s.io/kube-proxy => k8s.io/kube-proxy v0.19.16
	k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.19.16
	k8s.io/kubectl => k8s.io/kubectl v0.19.16
	k8s.io/kubelet => k8s.io/kubelet v0.19.16
	k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.19.16
	k8s.io/metrics => k8s.io/metrics v0.19.16
	k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.19.16
)
