package values

import (
	"strings"
	"testing"
)

func TestGetComponentsFromReleaseManifest(t *testing.T) {
	type args struct {
		url string
	}
	tests := []struct {
		name           string
		args           args
		want           string
		wantErr        bool
		errMsgContains string
	}{
		{
			name:    "error_if_invalid_URL",
			args:    args{url: "Hello!_I'm_an_invalid_URL"},
			want:    "",
			wantErr: true,
		},
		{
			name:           "error_if_nonexistent_URL",
			args:           args{url: "https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-FOOOO.yaml"},
			want:           "",
			wantErr:        true,
			errMsgContains: "status code 403",
		},
		{
			name:    "return_expected_if_valid_URL",
			args:    args{url: validDataOne.url},
			want:    validDataOne.expectedOutput,
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := GetComponentsFromReleaseManifest(tt.args.url)
			if err != nil {
				if !tt.wantErr {
					t.Errorf("GetComponentsFromReleaseManifest() error = %v, wantErr %v", err, tt.wantErr)
					return
				}
				if len(tt.errMsgContains) > 0 && !strings.Contains(err.Error(), tt.errMsgContains) {
					t.Errorf("GetComponentsFromReleaseManifest() got = %q, expected error message to contain %q",
						err, tt.errMsgContains)
					return
				}
			}
			if got != tt.want {
				t.Errorf("GetComponentsFromReleaseManifest() got = %v, want %v", got, tt.want)
			}
		})
	}
}

type validData struct {
	url            string
	expectedOutput string
}

var validDataOne = validData{
	url: "https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-1.yaml",
	expectedOutput: `| Name | Version | URI |
|------|---------|-----|
| aws-iam-authenticator | v0.5.8 | public.ecr.aws/eks-distro/kubernetes-sigs/aws-iam-authenticator:v0.5.8-eks-1-23-1 |
| coredns | v1.8.7 | public.ecr.aws/eks-distro/coredns/coredns:v1.8.7-eks-1-23-1 |
| csi-snapshotter | v5.0.1 | public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/csi-snapshotter:v5.0.1-eks-1-23-1 |
| etcd | v3.5.3 | public.ecr.aws/eks-distro/etcd-io/etcd:v3.5.3-eks-1-23-1 |
| external-attacher | v3.4.0 | public.ecr.aws/eks-distro/kubernetes-csi/external-attacher:v3.4.0-eks-1-23-1 |
| external-provisioner | v3.1.0 | public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner:v3.1.0-eks-1-23-1 |
| external-resizer | v1.4.0 | public.ecr.aws/eks-distro/kubernetes-csi/external-resizer:v1.4.0-eks-1-23-1 |
| go-runner | v0.13.0 | public.ecr.aws/eks-distro/kubernetes/go-runner:v0.13.0-eks-1-23-1 |
| kube-apiserver | v1.23.6 | public.ecr.aws/eks-distro/kubernetes/kube-apiserver:v1.23.6-eks-1-23-1 |
| kube-controller-manager | v1.23.6 | public.ecr.aws/eks-distro/kubernetes/kube-controller-manager:v1.23.6-eks-1-23-1 |
| kube-proxy | v1.23.6 | public.ecr.aws/eks-distro/kubernetes/kube-proxy:v1.23.6-eks-1-23-1 |
| kube-proxy-base | v0.13.0 | public.ecr.aws/eks-distro/kubernetes/kube-proxy-base:v0.13.0-eks-1-23-1 |
| kube-scheduler | v1.23.6 | public.ecr.aws/eks-distro/kubernetes/kube-scheduler:v1.23.6-eks-1-23-1 |
| livenessprobe | v2.7.0 | public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe:v2.7.0-eks-1-23-1 |
| metrics-server | v0.6.1 | public.ecr.aws/eks-distro/kubernetes-sigs/metrics-server:v0.6.1-eks-1-23-1 |
| node-driver-registrar | v2.5.0 | public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar:v2.5.0-eks-1-23-1 |
| pause | v1.23.6 | public.ecr.aws/eks-distro/kubernetes/pause:v1.23.6-eks-1-23-1 |
| snapshot-controller | v5.0.1 | public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-controller:v5.0.1-eks-1-23-1 |
| snapshot-validation-webhook | v5.0.1 | public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-validation-webhook:v5.0.1-eks-1-23-1 |`,
}
