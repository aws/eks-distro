module github.com/kubernetes-csi/external-provisioner

go 1.17

require (
	github.com/container-storage-interface/spec v1.6.0
	github.com/golang/mock v1.5.0
	github.com/google/gofuzz v1.2.0 // indirect
	github.com/google/uuid v1.3.0 // indirect
	github.com/imdario/mergo v0.3.12 // indirect
	github.com/kubernetes-csi/csi-lib-utils v0.11.0
	github.com/kubernetes-csi/csi-test/v4 v4.0.2
	github.com/kubernetes-csi/external-snapshotter/client/v6 v6.0.1
	github.com/miekg/dns v1.1.48 // indirect
	github.com/prometheus/client_golang v1.12.1
	github.com/spf13/pflag v1.0.5
	github.com/stretchr/testify v1.7.0
	google.golang.org/grpc v1.45.0
	google.golang.org/protobuf v1.28.0
	k8s.io/api v0.24.0
	k8s.io/apimachinery v0.24.0
	k8s.io/apiserver v0.24.0
	k8s.io/client-go v0.24.0
	k8s.io/component-base v0.24.0
	k8s.io/component-helpers v0.24.0-beta.0
	k8s.io/csi-translation-lib v0.23.5
	k8s.io/klog/v2 v2.60.1
	sigs.k8s.io/controller-runtime v0.11.2
	sigs.k8s.io/sig-storage-lib-external-provisioner/v8 v8.0.0
)

require (
	github.com/PuerkitoBio/purell v1.1.1 // indirect
	github.com/PuerkitoBio/urlesc v0.0.0-20170810143723-de5bf2ad4578 // indirect
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/blang/semver/v4 v4.0.0 // indirect
	github.com/cespare/xxhash/v2 v2.1.2 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/emicklei/go-restful v2.15.0+incompatible // indirect
	github.com/evanphx/json-patch v5.6.0+incompatible // indirect
	github.com/go-logr/logr v1.2.3 // indirect
	github.com/go-openapi/jsonpointer v0.19.5 // indirect
	github.com/go-openapi/jsonreference v0.19.6 // indirect
	github.com/go-openapi/swag v0.21.1 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/golang/groupcache v0.0.0-20210331224755-41bb18bfe9da // indirect
	github.com/golang/protobuf v1.5.2 // indirect
	github.com/google/gnostic v0.6.8 // indirect
	github.com/google/go-cmp v0.5.7 // indirect
	github.com/inconshreveable/mousetrap v1.0.0 // indirect
	github.com/josharian/intern v1.0.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/mailru/easyjson v0.7.7 // indirect
	github.com/matttproud/golang_protobuf_extensions v1.0.2-0.20181231171920-c182affec369 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/prometheus/client_model v0.2.0 // indirect
	github.com/prometheus/common v0.33.0 // indirect
	github.com/prometheus/procfs v0.7.3 // indirect
	github.com/spf13/cobra v1.4.0 // indirect
	golang.org/x/mod v0.6.0-dev.0.20220106191415-9b9b3d81d5e3 // indirect
	golang.org/x/net v0.0.0-20220403103023-749bd193bc2b // indirect
	golang.org/x/oauth2 v0.0.0-20220309155454-6242fa91716a // indirect
	golang.org/x/sys v0.0.0-20220406163625-3f8b81556e12 // indirect
	golang.org/x/term v0.0.0-20210927222741-03fcf44c2211 // indirect
	golang.org/x/text v0.3.7 // indirect
	golang.org/x/time v0.0.0-20220224211638-0e9765cccd65 // indirect
	golang.org/x/tools v0.1.10 // indirect
	golang.org/x/xerrors v0.0.0-20200804184101-5ec99f83aff1 // indirect
	google.golang.org/appengine v1.6.7 // indirect
	google.golang.org/genproto v0.0.0-20220405205423-9d709892a2bf // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	k8s.io/apiextensions-apiserver v0.24.0-beta.0 // indirect
	k8s.io/klog v1.0.0 // indirect
	k8s.io/kube-openapi v0.0.0-20220401212409-b28bf2818661 // indirect
	k8s.io/utils v0.0.0-20220210201930-3a6ce19ff2f9 // indirect
	sigs.k8s.io/json v0.0.0-20211208200746-9f7c6b3444d2 // indirect
	sigs.k8s.io/structured-merge-diff/v4 v4.2.1 // indirect
	sigs.k8s.io/yaml v1.3.0 // indirect
)

replace k8s.io/api => k8s.io/api v0.24.0

replace k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.24.0

replace k8s.io/apimachinery => k8s.io/apimachinery v0.24.0

replace k8s.io/apiserver => k8s.io/apiserver v0.24.0

replace k8s.io/cli-runtime => k8s.io/cli-runtime v0.24.0

replace k8s.io/client-go => k8s.io/client-go v0.24.0

replace k8s.io/cloud-provider => k8s.io/cloud-provider v0.24.0

replace k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.24.0

replace k8s.io/code-generator => k8s.io/code-generator v0.24.0

replace k8s.io/component-base => k8s.io/component-base v0.24.0

replace k8s.io/component-helpers => k8s.io/component-helpers v0.24.0

replace k8s.io/controller-manager => k8s.io/controller-manager v0.24.0

replace k8s.io/cri-api => k8s.io/cri-api v0.24.0

replace k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.24.0

replace k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.24.0

replace k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.24.0

replace k8s.io/kube-proxy => k8s.io/kube-proxy v0.24.0

replace k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.24.0

replace k8s.io/kubectl => k8s.io/kubectl v0.24.0

replace k8s.io/kubelet => k8s.io/kubelet v0.24.0

replace k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.24.0

replace k8s.io/metrics => k8s.io/metrics v0.24.0

replace k8s.io/mount-utils => k8s.io/mount-utils v0.24.0

replace k8s.io/pod-security-admission => k8s.io/pod-security-admission v0.24.0

replace k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.24.0

replace k8s.io/sample-cli-plugin => k8s.io/sample-cli-plugin v0.24.0

replace k8s.io/sample-controller => k8s.io/sample-controller v0.24.0
