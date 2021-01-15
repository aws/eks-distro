package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

type Command struct {
	releaseBranch        string
	gitRoot              string
	release              string
	artifactBucket       string
	uploadToPublicBucket bool
	args                 []string
}

func (cmd Command) run(runMake bool, uploadArtifacts bool, targetPath string) {
	if runMake == true {
		// Add a specific target
		cmd.args[1] = cmd.args[1] + targetPath
		command := exec.Command("make", cmd.args...)
		output, err := command.CombinedOutput()
		if err != nil {
			log.Fatalf("There was an error running make: %v. Make output:\n%v", err, string(output))
		}
		fmt.Printf("Output of the make command for %v:\n %v", targetPath, string(output))
		// Remove the target name from the build args
		cmd.args[1] = cmd.gitRoot + "/projects/"
		if uploadArtifacts == true {
			if cmd.uploadToPublicBucket == true {
				command = exec.Command("/bin/bash", cmd.gitRoot+"/release/lib/create_final_dir.sh", cmd.releaseBranch, cmd.release, cmd.artifactBucket, targetPath)
				output, err = command.CombinedOutput()
				if err != nil {
					log.Fatalf("There was an error running the create_final_dir script: %v. Output:\n%v", err, string(output))
				}
				fmt.Printf("Output of the create_final_dir script for %v:\n %v", targetPath, string(output))
			}
			if targetPath == "kubernetes/kubernetes" {
				command = exec.Command("/bin/bash", "-c", fmt.Sprintf("mv %s/projects/%s/_output/%s/* /logs/artifacts", cmd.gitRoot, targetPath, cmd.releaseBranch))
			} else {
				command = exec.Command("/bin/bash", "-c", fmt.Sprintf("mv %s/projects/%s/_output/tar/* /logs/artifacts", cmd.gitRoot, targetPath))
			}
			output, err = command.CombinedOutput()
			if err != nil {
				log.Fatalf("There was an error running mv: %v. Output:\n%v", err, string(output))
			}
			fmt.Printf("Successfully moved artifacts to /logs/artifacts directory for %v.\n", targetPath)
		}
	}
}

func NewCommand() *Command {
	cmd := new(Command)
	cmd.releaseBranch = os.Args[2]
	cmd.release = os.Args[3]
	cmd.artifactBucket = os.Args[11]
	cmd.uploadToPublicBucket, _ = strconv.ParseBool(os.Args[12])
	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		log.Fatalf("There was an error running the git command: %v", err)
	}
	cmd.gitRoot = strings.Fields(string(gitRootOutput))[0]
	cmd.args = []string{"-C", cmd.gitRoot + "/projects/", os.Args[1],
		"RELEASE_BRANCH=" + os.Args[2],
		"RELEASE=" + os.Args[3],
		"DEVELOPMENT=" + os.Args[4],
		"AWS_REGION=" + os.Args[5],
		"AWS_ACCOUNT_ID=" + os.Args[6],
		"BASE_IMAGE=" + os.Args[7],
		"IMAGE_REPO=" + os.Args[8],
		"GO_RUNNER_IMAGE=" + os.Args[9],
		"KUBE_PROXY_BASE_IMAGE=" + os.Args[10],
		"IMAGE_TAG='$(GIT_TAG)-$(PULL_BASE_SHA)'"}
	return cmd
}

func main() {
	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		log.Fatalf("There was an error running the git command: %v", err)
	}
	gitRoot := strings.Fields(string(gitRootOutput))[0]
	kubernetesChanged := false
	coreDnsChanged := false
	cniPluginsChanged := false
	iamAuthChanged := false
	etcdChanged := false
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
		if strings.Contains(file, "etcd-io/etcd") {
			etcdChanged = true
		}
		if file == "Makefile" {
			kubernetesChanged = true
			coreDnsChanged = true
			cniPluginsChanged = true
			iamAuthChanged = true
			etcdChanged = true
		}
	}

	cmd := NewCommand()
	cmd.run(cniPluginsChanged, true, "containernetworking/plugins")
	cmd.run(iamAuthChanged, true, "kubernetes-sigs/aws-iam-authenticator")
	cmd.run(coreDnsChanged, false, "coredns/coredns")
	cmd.run(etcdChanged, true, "etcd-io/etcd")
	cmd.run(kubernetesChanged, true, "kubernetes/kubernetes")
}
