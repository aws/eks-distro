module github.com/kubernetes-csi/external-snapshotter/v4

go 1.16

require (
	github.com/container-storage-interface/spec v1.5.0
	github.com/fsnotify/fsnotify v1.4.9
	github.com/golang/mock v1.4.4
	github.com/golang/protobuf v1.5.2
	github.com/google/gofuzz v1.2.0
	github.com/imdario/mergo v0.3.11 // indirect
	github.com/kubernetes-csi/csi-lib-utils v0.10.0
	github.com/kubernetes-csi/csi-test/v4 v4.0.2
	github.com/kubernetes-csi/external-snapshotter/client/v4 v4.1.0
	github.com/prometheus/client_golang v1.11.0
	github.com/prometheus/client_model v0.2.0
	github.com/prometheus/common v0.26.0
	github.com/spf13/cobra v1.1.3
	golang.org/x/oauth2 v0.0.0-20201208152858-08078c50e5b5 // indirect
	google.golang.org/appengine v1.6.7 // indirect
	google.golang.org/grpc v1.38.0
	k8s.io/api v0.22.0
	k8s.io/apimachinery v0.22.0
	k8s.io/client-go v0.22.0
	k8s.io/component-base v0.22.0
	k8s.io/klog/v2 v2.9.0
	k8s.io/kubernetes v1.21.5
)

replace (
	github.com/kubernetes-csi/external-snapshotter/client/v4 => ./client
	k8s.io/api => k8s.io/api v0.22.0
	k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.22.0
	k8s.io/apimachinery => k8s.io/apimachinery v0.22.0
	k8s.io/apiserver => k8s.io/apiserver v0.22.0
	k8s.io/cli-runtime => k8s.io/cli-runtime v0.22.0
	k8s.io/client-go => k8s.io/client-go v0.22.0
	k8s.io/cloud-provider => k8s.io/cloud-provider v0.22.0
	k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.22.0
	k8s.io/code-generator => k8s.io/code-generator v0.22.0
	k8s.io/component-base => k8s.io/component-base v0.22.0
	k8s.io/component-helpers => k8s.io/component-helpers v0.22.0
	k8s.io/controller-manager => k8s.io/controller-manager v0.22.0
	k8s.io/cri-api => k8s.io/cri-api v0.22.0
	k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.22.0
	k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.22.0
	k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.22.0
	k8s.io/kube-proxy => k8s.io/kube-proxy v0.22.0
	k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.22.0
	k8s.io/kubectl => k8s.io/kubectl v0.22.0
	k8s.io/kubelet => k8s.io/kubelet v0.22.0
	k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.22.0
	k8s.io/metrics => k8s.io/metrics v0.22.0
	k8s.io/mount-utils => k8s.io/mount-utils v0.22.0
	k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.22.0
)
