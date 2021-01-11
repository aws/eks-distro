package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)
func runCommand(runMake bool, path string, target string, args string) {
	if (runMake == == true) {
		err := exec.Command("make", "-C", path, target, args).Output()
		if err != nil {
			log.Fatalf("There was an error running make command: %v", err)
		}
	}
}

func main() {
	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		log.Fatalf("There was an error running the git command: %v", err)
	}
	gitRoot := strings.Fields(string(gitRootOutput))[0]
	pullBaseSha := os.Getenv("PULL_BASE_SHA")
	pullPullSha := os.Getenv("PULL_PULL_SHA")

	kubernetesChanged := false;
	coreDnsChanged := false;
	cniPluginsChanged := false;
	iamAuthChanged := false;
	gitDiffCommand := []string{"git", "-C", gitRoot, "diff", "--name-only", "HEAD^", "HEAD"}
	fmt.Println("\n", strings.Join(gitDiffCommand, " "))

	gitDiffOutput, err := exec.Command("git", gitDiffCommand[1:]...).Output()
	filesChanged := strings.Fields(string(gitDiffOutput))
	for _, file := range filesChanged {
		if strings.Contains(file, "kubernetes/kubernetes") {
			kubernetesChanged = true
		}
		if strings.Contains(file, "coredns/coredns") {
			coreDnsChanged = true
		}
                if strings.Contains(file, "containernetworking/plugins") {
                        cniPluginsChanged = true
                }
                if strings.Contains(file, "kubernetes-sigs/aws-iam-authenticator") {
                        iamAuthChanged = true
                }
	}
	buildArg := fmt.Sprintf("RELEASE_BRANCH=%s RELEASE=%s DEVELOPMENT=%s AWS_REGION=%s AWS_ACCOUNT_ID=%s BASE_IMAGE=%s IMAGE_REPO=%s IMAGE_TAG=%s",
			os.Args[2], os.Args[3], os.Args[4], os.Args[5], os.Args[6], os.Args[7], os.Args[8], os.Args[11])
	kubeBuildArg := fmt.Sprintf("%s RELEASE_BRANCH=%s RELEASE=%s DEVELOPMENT=%s AWS_REGION=%s AWS_ACCOUNT_ID=%s KUBE_PROXY_BASE_IMAGE=%s GO_RUNNER_IMAGE=%s IMAGE_TAG=%s",
                        os.Args[2], os.Args[3], os.Args[4], os.Args[5], os.Args[6], os.Args[9], os.Args[10], os.Args[11])
	runCommand(kubernetesChanged, "kubernetes/kubernetes", os.Args[1], kubeBuildArg)
	runCommand(coreDnsChanged, "coredns/coredns", os.Args[1], buildArg)
	runCommand(cniPluginsChanged, "containernetworking/plugins", os.Args[1], buildArg)
	runCommand(iamAuthChanged, "kubernetes-sigs/aws-iam-authenticator", os.Args[1], buildArg)
}
