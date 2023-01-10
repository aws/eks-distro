module github.com/kubernetes-csi/node-driver-registrar

go 1.18

require (
	github.com/kubernetes-csi/csi-lib-utils v0.11.0
	golang.org/x/sys v0.0.0-20220722155257-8c9f86f7a55f
	google.golang.org/grpc v1.50.1
	k8s.io/client-go v0.25.2
	k8s.io/klog/v2 v2.80.1
	k8s.io/kubelet v0.25.2
)

require (
	github.com/PuerkitoBio/purell v1.1.1 // indirect
	github.com/PuerkitoBio/urlesc v0.0.0-20170810143723-de5bf2ad4578 // indirect
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/blang/semver/v4 v4.0.0 // indirect
	github.com/cespare/xxhash/v2 v2.1.2 // indirect
	github.com/container-storage-interface/spec v1.6.0 // indirect
	github.com/emicklei/go-restful/v3 v3.8.0 // indirect
	github.com/go-logr/logr v1.2.3 // indirect
	github.com/go-openapi/jsonpointer v0.19.5 // indirect
	github.com/go-openapi/jsonreference v0.19.5 // indirect
	github.com/go-openapi/swag v0.19.14 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/golang/protobuf v1.5.2 // indirect
	github.com/google/gnostic v0.5.7-v3refs // indirect
	github.com/josharian/intern v1.0.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/mailru/easyjson v0.7.6 // indirect
	github.com/matttproud/golang_protobuf_extensions v1.0.1 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/prometheus/client_golang v1.12.1 // indirect
	github.com/prometheus/client_model v0.2.0 // indirect
	github.com/prometheus/common v0.32.1 // indirect
	github.com/prometheus/procfs v0.7.3 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	golang.org/x/net v0.0.0-20220722155237-a158d28d115b // indirect
	golang.org/x/text v0.3.7 // indirect
	google.golang.org/genproto v0.0.0-20220502173005-c8bf987b8c21 // indirect
	google.golang.org/protobuf v1.28.0 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	k8s.io/apimachinery v0.25.2 // indirect
	k8s.io/component-base v0.25.2 // indirect
	k8s.io/kube-openapi v0.0.0-20220803162953-67bda5d908f1 // indirect
)

replace k8s.io/api => k8s.io/api v0.25.2

replace k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.25.2

replace k8s.io/apimachinery => k8s.io/apimachinery v0.25.2

replace k8s.io/apiserver => k8s.io/apiserver v0.25.2

replace k8s.io/cli-runtime => k8s.io/cli-runtime v0.25.2

replace k8s.io/client-go => k8s.io/client-go v0.25.2

replace k8s.io/cloud-provider => k8s.io/cloud-provider v0.25.2

replace k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.25.2

replace k8s.io/code-generator => k8s.io/code-generator v0.25.2

replace k8s.io/component-base => k8s.io/component-base v0.25.2

replace k8s.io/component-helpers => k8s.io/component-helpers v0.25.2

replace k8s.io/controller-manager => k8s.io/controller-manager v0.25.2

replace k8s.io/cri-api => k8s.io/cri-api v0.25.2

replace k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.25.2

replace k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.25.2

replace k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.25.2

replace k8s.io/kube-proxy => k8s.io/kube-proxy v0.25.2

replace k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.25.2

replace k8s.io/kubectl => k8s.io/kubectl v0.25.2

replace k8s.io/kubelet => k8s.io/kubelet v0.25.2

replace k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.25.2

replace k8s.io/metrics => k8s.io/metrics v0.25.2

replace k8s.io/mount-utils => k8s.io/mount-utils v0.25.2

replace k8s.io/pod-security-admission => k8s.io/pod-security-admission v0.25.2

replace k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.25.2

replace k8s.io/sample-cli-plugin => k8s.io/sample-cli-plugin v0.25.2

replace k8s.io/sample-controller => k8s.io/sample-controller v0.25.2
