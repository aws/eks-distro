package internal

import (
	"os/exec"
	"path/filepath"
	"strings"
)

var gitRootOutput string = getRootDirectory()


type ReleaseManager interface {
	GetReleaseNumber()	string
	GetReleaseBranch() string
	GetReleaseEnvironment() string
}

func getRootDirectory() string {
	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		panic("bad")
	}

	return strings.Join(strings.Fields(string(gitRootOutput)), "")
}


//func GetRootDirectory() (string, error) {
//	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
//	if err != nil {
//		return "", err
//	}
//	return strings.Join(strings.Fields(string(gitRootOutput)), ""), nil
//}


func GetKubeGitVersionFilePath(rm ReleaseManager) (string, error) {
	//gitRoot, err := getRootDirectory()
	//if err != nil {
	//	return "", err
	//}
	return filepath.Join(gitRootOutput, "projects/kubernetes/kubernetes", rm.GetReleaseBranch(), "KUBE_GIT_VERSION_FILE"), nil
}

func GetReleasePath(rm ReleaseManager) (string, error) {
	return filepath.Join(gitRootOutput, "release", rm.GetReleaseBranch(), rm.GetReleaseEnvironment(), "RELEASE"), nil
}

func GetReleaseDocsPath(rm ReleaseManager) (string, error) {
	return filepath.Join(gitRootOutput, "docs/contents/releases", rm.GetReleaseBranch(), rm.GetReleaseNumber()), nil
}