module github.com/kubernetes-csi/external-snapshotter/v6

go 1.20

require (
	github.com/container-storage-interface/spec v1.8.0
	github.com/evanphx/json-patch v5.7.0+incompatible
	github.com/fsnotify/fsnotify v1.6.0
	github.com/golang/mock v1.6.0
	github.com/google/gofuzz v1.2.0
	github.com/kubernetes-csi/csi-lib-utils v0.14.0
	github.com/kubernetes-csi/csi-test/v4 v4.4.0
	github.com/kubernetes-csi/external-snapshotter/client/v6 v6.3.0
	github.com/prometheus/client_golang v1.16.0
	github.com/prometheus/client_model v0.4.0
	github.com/prometheus/common v0.44.0
	github.com/spf13/cobra v1.7.0
	google.golang.org/grpc v1.58.0
	google.golang.org/protobuf v1.31.0
	k8s.io/api v0.28.0
	k8s.io/apimachinery v0.28.0
	k8s.io/client-go v0.28.0
	k8s.io/component-base v0.28.0
	k8s.io/component-helpers v0.28.0
	k8s.io/klog/v2 v2.100.1
)

require (
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/blang/semver/v4 v4.0.0 // indirect
	github.com/cespare/xxhash/v2 v2.2.0 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/emicklei/go-restful/v3 v3.10.1 // indirect
	github.com/go-logr/logr v1.2.4 // indirect
	github.com/go-openapi/jsonpointer v0.19.6 // indirect
	github.com/go-openapi/jsonreference v0.20.2 // indirect
	github.com/go-openapi/swag v0.22.3 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/golang/groupcache v0.0.0-20210331224755-41bb18bfe9da // indirect
	github.com/golang/protobuf v1.5.3 // indirect
	github.com/google/gnostic-models v0.6.8 // indirect
	github.com/google/go-cmp v0.5.9 // indirect
	github.com/google/uuid v1.3.0 // indirect
	github.com/imdario/mergo v0.3.13 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/josharian/intern v1.0.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/mailru/easyjson v0.7.7 // indirect
	github.com/matttproud/golang_protobuf_extensions v1.0.4 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/prometheus/procfs v0.10.1 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	golang.org/x/net v0.13.0 // indirect
	golang.org/x/oauth2 v0.10.0 // indirect
	golang.org/x/sys v0.10.0 // indirect
	golang.org/x/term v0.10.0 // indirect
	golang.org/x/text v0.11.0 // indirect
	golang.org/x/time v0.3.0 // indirect
	google.golang.org/appengine v1.6.7 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20230711160842-782d3b101e98 // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	k8s.io/kube-openapi v0.0.0-20230717233707-2695361300d9 // indirect
	k8s.io/utils v0.0.0-20230406110748-d93618cff8a2 // indirect
	sigs.k8s.io/json v0.0.0-20221116044647-bc3834ca7abd // indirect
	sigs.k8s.io/structured-merge-diff/v4 v4.2.3 // indirect
	sigs.k8s.io/yaml v1.3.0 // indirect
)

replace github.com/kubernetes-csi/external-snapshotter/client/v6 => ./client

replace k8s.io/api => k8s.io/api v0.28.0

replace k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.28.0

replace k8s.io/apimachinery => k8s.io/apimachinery v0.28.0

replace k8s.io/apiserver => k8s.io/apiserver v0.28.0

replace k8s.io/cli-runtime => k8s.io/cli-runtime v0.28.0

replace k8s.io/client-go => k8s.io/client-go v0.28.0

replace k8s.io/cloud-provider => k8s.io/cloud-provider v0.28.0

replace k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.28.0

replace k8s.io/code-generator => k8s.io/code-generator v0.28.0

replace k8s.io/component-base => k8s.io/component-base v0.28.0

replace k8s.io/component-helpers => k8s.io/component-helpers v0.28.0

replace k8s.io/controller-manager => k8s.io/controller-manager v0.28.0

replace k8s.io/cri-api => k8s.io/cri-api v0.28.0

replace k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.28.0

replace k8s.io/dynamic-resource-allocation => k8s.io/dynamic-resource-allocation v0.28.0

replace k8s.io/kms => k8s.io/kms v0.28.0

replace k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.28.0

replace k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.28.0

replace k8s.io/kube-proxy => k8s.io/kube-proxy v0.28.0

replace k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.28.0

replace k8s.io/kubectl => k8s.io/kubectl v0.28.0

replace k8s.io/kubelet => k8s.io/kubelet v0.28.0

replace k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.28.0

replace k8s.io/metrics => k8s.io/metrics v0.28.0

replace k8s.io/mount-utils => k8s.io/mount-utils v0.28.0

replace k8s.io/pod-security-admission => k8s.io/pod-security-admission v0.28.0

replace k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.28.0