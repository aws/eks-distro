module github.com/kubernetes-csi/external-attacher

go 1.16

require (
	github.com/container-storage-interface/spec v1.5.0
	github.com/davecgh/go-spew v1.1.1
	github.com/evanphx/json-patch v4.12.0+incompatible
	github.com/golang/mock v1.5.0
	github.com/golang/protobuf v1.5.2
	github.com/google/gofuzz v1.2.0 // indirect
	github.com/imdario/mergo v0.3.12 // indirect
	github.com/kubernetes-csi/csi-lib-utils v0.10.0
	github.com/kubernetes-csi/csi-test/v4 v4.0.2
	google.golang.org/grpc v1.40.0
	k8s.io/api v0.23.0
	k8s.io/apimachinery v0.23.0
	k8s.io/client-go v0.23.0
	k8s.io/component-base v0.23.0 // indirect
	k8s.io/csi-translation-lib v0.23.0
	k8s.io/klog/v2 v2.30.0
)

replace k8s.io/api => k8s.io/api v0.23.0

replace k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.23.0

replace k8s.io/apimachinery => k8s.io/apimachinery v0.23.0

replace k8s.io/apiserver => k8s.io/apiserver v0.23.0

replace k8s.io/cli-runtime => k8s.io/cli-runtime v0.23.0

replace k8s.io/client-go => k8s.io/client-go v0.23.0

replace k8s.io/cloud-provider => k8s.io/cloud-provider v0.23.0

replace k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.23.0

replace k8s.io/code-generator => k8s.io/code-generator v0.23.0

replace k8s.io/component-base => k8s.io/component-base v0.23.0

replace k8s.io/component-helpers => k8s.io/component-helpers v0.23.0

replace k8s.io/controller-manager => k8s.io/controller-manager v0.23.0

replace k8s.io/cri-api => k8s.io/cri-api v0.23.0

replace k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.23.0

replace k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.23.0

replace k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.23.0

replace k8s.io/kube-proxy => k8s.io/kube-proxy v0.23.0

replace k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.23.0

replace k8s.io/kubectl => k8s.io/kubectl v0.23.0

replace k8s.io/kubelet => k8s.io/kubelet v0.23.0

replace k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.23.0

replace k8s.io/metrics => k8s.io/metrics v0.23.0

replace k8s.io/mount-utils => k8s.io/mount-utils v0.23.0

replace k8s.io/pod-security-admission => k8s.io/pod-security-admission v0.23.0

replace k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.23.0

replace k8s.io/sample-cli-plugin => k8s.io/sample-cli-plugin v0.23.0

replace k8s.io/sample-controller => k8s.io/sample-controller v0.23.0
