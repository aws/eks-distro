package release

import (
	"reflect"
	"testing"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
)

const (
	validCT            = changetype.Docs
	validReleaseBranch = "1-24" // update when 1-24 no longer supported

	// Only valid if Release was made with override number
	validOverrideNumber         = "1"
	validKubernetesGitTag       = "v1.24.6"
	validTag                    = "v1-24-eks-1"
	validManifestURL            = "https://distro.eks.amazonaws.com/kubernetes-1-24/kubernetes-1-24-eks-1.yaml"
	validKubernetesMinorVersion = "1.24"
	validKubernetesURL          = "https://github.com/kubernetes/kubernetes/release/tag/" + validKubernetesGitTag
)

var (
	// Only valid if Release was made with override number
	testFields = fields{
		branch:           validReleaseBranch,
		number:           validOverrideNumber,
		kubernetesGitTag: validKubernetesGitTag,
		tag:              validTag,
		manifestURL:      validManifestURL,
	}
)

type fields struct {
	branch           string
	number           string
	kubernetesGitTag string
	tag              string
	manifestURL      string
}

func TestNewRelease(t *testing.T) {
	type args struct {
		rb string
		ct changetype.ChangeType
	}
	tests := []struct {
		name           string
		args           args
		want           *Release
		wantErr        bool
		errMsgContains string
	}{
		{
			name:           "error_if_empty_release_branch",
			args:           args{rb: "", ct: validCT},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "release branch cannot be an empty string",
		},
		{
			name:           "error_if_invalid_release_branch",
			args:           args{rb: "foo", ct: validCT},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "release branch cannot be an empty string",
		},
		{
			name:           "error_if_change_type_is_dev",
			args:           args{rb: validReleaseBranch, ct: changetype.Dev},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "release cannot be for prod or dev",
		},
		{
			name:           "error_if_change_type_is_prod",
			args:           args{rb: validReleaseBranch, ct: changetype.Prod},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "release cannot be for prod or dev",
		},
		// TODO add test for no errors
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := NewRelease(tt.args.rb, tt.args.ct)
			if (err != nil) != tt.wantErr {
				t.Errorf("NewRelease() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("NewRelease() got = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestNewReleaseOverrideNumber(t *testing.T) {
	type args struct {
		rb             string
		overrideNumber string
	}
	tests := []struct {
		name           string
		args           args
		want           *Release
		wantErr        bool
		errMsgContains string
	}{
		{
			name:           "error_if_empty_release_branch",
			args:           args{rb: "", overrideNumber: validOverrideNumber},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "release branch cannot be an empty string",
		},
		{
			name:           "error_if_invalid_release_branch",
			args:           args{rb: "foo", overrideNumber: validOverrideNumber},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "release branch cannot be an empty string",
		},
		{
			name:           "error_if_override_number_is_empty",
			args:           args{rb: validReleaseBranch, overrideNumber: ""},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "expected non-empty override number",
		},
		{
			name:           "error_if_override_number_is_only_whitespace",
			args:           args{rb: validReleaseBranch, overrideNumber: "     "},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "release cannot be for prod or dev",
		},
		{
			name:           "error_if_override_number_is_less_than_min",
			args:           args{rb: validReleaseBranch, overrideNumber: ""},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "expected non-empty override number",
		},
		{
			name:           "error_if_override_number_is_greater_than_local",
			args:           args{rb: validReleaseBranch, overrideNumber: "9999999999999"},
			want:           &Release{},
			wantErr:        true,
			errMsgContains: "expected non-empty override number",
		},
		{
			name: "returns_release_if_valid_input",
			args: args{rb: validReleaseBranch, overrideNumber: validOverrideNumber},
			want: &Release{
				branch:           validReleaseBranch,
				number:           validOverrideNumber,
				kubernetesGitTag: validKubernetesGitTag,
				tag:              validTag,
				manifestURL:      validManifestURL,
			},
			wantErr: false,
		},
		// TODO: add test to confirm override with local number and NewRelease make the same Release
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := NewReleaseOverrideNumber(tt.args.rb, tt.args.overrideNumber)
			if (err != nil) != tt.wantErr {
				t.Errorf("NewReleaseOverrideNumber() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("NewReleaseOverrideNumber() got = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestRelease_Branch(t *testing.T) {
	tests := []struct {
		name   string
		fields fields
		want   string
	}{
		{
			name:   "returns_release_branch",
			fields: testFields,
			want:   testFields.branch,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &Release{
				branch:           tt.fields.branch,
				number:           tt.fields.number,
				kubernetesGitTag: tt.fields.kubernetesGitTag,
				tag:              tt.fields.tag,
				manifestURL:      tt.fields.manifestURL,
			}
			if got := r.Branch(); got != tt.want {
				t.Errorf("Branch() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestRelease_KubernetesGitTag(t *testing.T) {
	tests := []struct {
		name   string
		fields fields
		want   string
	}{
		{
			name:   "returns_release_kubernetes_git_tag",
			fields: testFields,
			want:   testFields.kubernetesGitTag,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &Release{
				branch:           tt.fields.branch,
				number:           tt.fields.number,
				kubernetesGitTag: tt.fields.kubernetesGitTag,
				tag:              tt.fields.tag,
				manifestURL:      tt.fields.manifestURL,
			}
			if got := r.KubernetesGitTag(); got != tt.want {
				t.Errorf("KubernetesGitTag() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestRelease_KubernetesMinorVersion(t *testing.T) {
	tests := []struct {
		name   string
		fields fields
		want   string
	}{
		{
			name:   "returns_release_kubernetes_minor_version",
			fields: testFields,
			want:   validKubernetesMinorVersion,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &Release{
				branch:           tt.fields.branch,
				number:           tt.fields.number,
				kubernetesGitTag: tt.fields.kubernetesGitTag,
				tag:              tt.fields.tag,
				manifestURL:      tt.fields.manifestURL,
			}
			if got := r.KubernetesMinorVersion(); got != tt.want {
				t.Errorf("KubernetesMinorVersion() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestRelease_KubernetesURL(t *testing.T) {
	tests := []struct {
		name   string
		fields fields
		want   string
	}{
		{
			name:   "returns_release_kubernetes_url",
			fields: testFields,
			want:   validKubernetesURL,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &Release{
				branch:           tt.fields.branch,
				number:           tt.fields.number,
				kubernetesGitTag: tt.fields.kubernetesGitTag,
				tag:              tt.fields.tag,
				manifestURL:      tt.fields.manifestURL,
			}
			if got := r.KubernetesURL(); got != tt.want {
				t.Errorf("KubernetesURL() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestRelease_ManifestURL(t *testing.T) {
	tests := []struct {
		name   string
		fields fields
		want   string
	}{
		{
			name:   "returns_release_manifest_url",
			fields: testFields,
			want:   testFields.manifestURL,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &Release{
				branch:           tt.fields.branch,
				number:           tt.fields.number,
				kubernetesGitTag: tt.fields.kubernetesGitTag,
				tag:              tt.fields.tag,
				manifestURL:      tt.fields.manifestURL,
			}
			if got := r.ManifestURL(); got != tt.want {
				t.Errorf("ManifestURL() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestRelease_Number(t *testing.T) {
	tests := []struct {
		name   string
		fields fields
		want   string
	}{
		{
			name:   "returns_release_number",
			fields: testFields,
			want:   testFields.number,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &Release{
				branch:           tt.fields.branch,
				number:           tt.fields.number,
				kubernetesGitTag: tt.fields.kubernetesGitTag,
				tag:              tt.fields.tag,
				manifestURL:      tt.fields.manifestURL,
			}
			if got := r.Number(); got != tt.want {
				t.Errorf("Number() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestRelease_Tag(t *testing.T) {
	tests := []struct {
		name   string
		fields fields
		want   string
	}{
		{
			name:   "returns_release_tag",
			fields: testFields,
			want:   testFields.tag,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &Release{
				branch:           tt.fields.branch,
				number:           tt.fields.number,
				kubernetesGitTag: tt.fields.kubernetesGitTag,
				tag:              tt.fields.tag,
				manifestURL:      tt.fields.manifestURL,
			}
			if got := r.Tag(); got != tt.want {
				t.Errorf("Tag() = %v, want %v", got, tt.want)
			}
		})
	}
}
