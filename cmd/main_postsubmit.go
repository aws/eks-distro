package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr
)

type Command struct {
	releaseBranch        string
	gitRoot              string
	release              string
	artifactBucket       string
	uploadToPublicBucket bool

	makeTarget string
	makeArgs   []string

	dryRun bool
}

func (c *Command) buildProject(projectPath string, uploadArtifacts bool) error {
	commandArgs := []string{
		"-C",
		filepath.Join(c.gitRoot, "projects", projectPath),
		c.makeTarget,
	}
	commandArgs = append(commandArgs, c.makeArgs...)

	cmd := exec.Command("make", commandArgs...)
	log.Printf("Executing: %s", strings.Join(cmd.Args, " "))
	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	if !c.dryRun {
		err := cmd.Run()
		if err != nil {
			return fmt.Errorf("Error running make: %v", err)
		}
	}

	if uploadArtifacts {
		if c.uploadToPublicBucket {
			cmd = exec.Command(
				"/bin/bash",
				filepath.Join(c.gitRoot, "release/lib/create_final_dir.sh"),
				c.releaseBranch,
				c.release,
				c.artifactBucket,
				projectPath,
			)
			cmd.Stdout = outputStream
			cmd.Stderr = errStream
			log.Printf("Executing: %s", strings.Join(cmd.Args, " "))
			if !c.dryRun {
				err := cmd.Run()
				if err != nil {
					return fmt.Errorf("Error running create_final_dir.sh: %v", err)
				}
			}
		}
		if projectPath == "kubernetes/kubernetes" {
			cmd = exec.Command(
				"/bin/bash",
				"-c",
				fmt.Sprintf("mv %s/projects/%s/_output/%s/* /logs/artifacts", c.gitRoot, projectPath, c.releaseBranch))
		} else {
			cmd = exec.Command(
				"/bin/bash",
				"-c",
				fmt.Sprintf("mv %s/projects/%s/_output/tar/* /logs/artifacts", c.gitRoot, projectPath))
		}
		cmd.Stdout = outputStream
		cmd.Stderr = errStream
		log.Printf("Executing: %s", strings.Join(cmd.Args, " "))
		if !c.dryRun {
			err := cmd.Run()
			if err != nil {
				return fmt.Errorf("Error running make: %v", err)
			}
		}
		log.Printf("Successfully moved artifacts to /logs/artifacts directory for %s", projectPath)
	}
	return nil
}

func main() {
	target := flag.String("target", "release", "Make target")
	releaseBranch := flag.String("release-branch", "1-18", "Release branch to test")
	release := flag.String("release", "1", "Release to test")
	development := flag.Bool("development", false, "Build as a development build")
	region := flag.String("region", "us-west-2", "AWS region to use")
	accountId := flag.String("account-id", "", "AWS Account ID to use")
	baseImage := flag.String("base-image", "", "Base container image")
	imageRepo := flag.String("image-repo", "", "Container image repository")
	goRunnerImage := flag.String("go-runner-image", "", "go-runner image")
	kubeProxyBase := flag.String("kube-proxy-base", "", "kube-proxy base image")
	artifactBucket := flag.String("artifact-bucket", "", "S3 bucket for artifacts")
	uploadToPublicBucket := flag.Bool("upload-to-s3", false, "Upload artifacts to s3 bucket")
	gitRoot := flag.String("git-root", "", "Git root directory")
	dryRun := flag.Bool("dry-run", false, "Echo out commands, but don't run them")

	flag.Parse()
	log.Printf("Running postsubmit - dry-run: %t", *dryRun)

	c := &Command{
		releaseBranch:        *releaseBranch,
		release:              *release,
		artifactBucket:       *artifactBucket,
		gitRoot:              *gitRoot,
		uploadToPublicBucket: *uploadToPublicBucket,
		makeTarget:           *target,
		dryRun:               *dryRun,
	}
	if c.gitRoot == "" {
		gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
		if err != nil {
			log.Fatalf("Error running finding git root: %v", err)
		}
		c.gitRoot = strings.Fields(string(gitRootOutput))[0]
	}
	c.makeArgs = []string{
		fmt.Sprintf("RELEASE_BRANCH=%s", c.releaseBranch),
		fmt.Sprintf("RELEASE=%s", c.release),
		fmt.Sprintf("DEVELOPMENT=%t", *development),
		fmt.Sprintf("AWS_REGION=%s", *region),
		fmt.Sprintf("AWS_ACCOUNT_ID=%s", *accountId),
		fmt.Sprintf("BASE_IMAGE=%s", *baseImage),
		fmt.Sprintf("IMAGE_REPO=%s", *imageRepo),
		fmt.Sprintf("GO_RUNNER_IMAGE=%s", *goRunnerImage),
		fmt.Sprintf("KUBE_PROXY_BASE_IMAGE=%s", *kubeProxyBase),
		"IMAGE_TAG='$(GIT_TAG)-$(PULL_BASE_SHA)'",
	}

	cmd := exec.Command("git", "-C", *gitRoot, "diff", "--name-only", "HEAD^", "HEAD")
	log.Printf("Executing command: %s", strings.Join(cmd.Args, " "))
	gitDiffOutput, err := cmd.Output()
	if err != nil {
		log.Fatalf("error running git diff: %v\n%s", err, string(gitDiffOutput))
	}
	filesChanged := strings.Fields(string(gitDiffOutput))

	allChanged := false
	projects := map[string]*struct {
		uploadArtifacts bool
		changed         bool
	}{
		"kubernetes/kubernetes": {
			uploadArtifacts: true,
		},
		"kubernetes/release": {
			uploadArtifacts: false,
		},
		"coredns/coredns": {
			uploadArtifacts: false,
		},
		"containernetworking/plugins": {
			uploadArtifacts: true,
		},
		"kubernetes-sigs/aws-iam-authenticator": {
			uploadArtifacts: true,
		},
		"kubernetes-sigs/metrics-server": {
			uploadArtifacts: false,
		},
		"etcd-io/etcd": {
			uploadArtifacts: true,
		},
		"kubernetes-csi/external-attacher": {
			uploadArtifacts: false,
		},
		"kubernetes-csi/external-resizer": {
			uploadArtifacts: false,
		},
		"kubernetes-csi/livenessprobe": {
			uploadArtifacts: false,
		},
		"kubernetes-csi/node-driver-registrar": {
			uploadArtifacts: false,
		},
		"kubernetes-csi/external-snapshotter": {
			uploadArtifacts: false,
		},
		"kubernetes-csi/external-provisioner": {
			uploadArtifacts: false,
		},
	}

	for _, file := range filesChanged {
		for projectPath := range projects {
			if strings.Contains(file, projectPath) {
				projects[projectPath].changed = true
			}
		}
		if file == "Makefile" {
			allChanged = true
		}
	}
	for projectPath, config := range projects {
		if config.changed || allChanged {
			err = c.buildProject(projectPath, config.uploadArtifacts)
			if err != nil {
				log.Fatalf("error building %s: %v", projectPath, err)
			}
		}
	}
}
