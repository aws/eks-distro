package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr
)

type Command struct {
	releaseBranch  string
	releaseVariant string
	gitRoot        string
	release        string
	artifactBucket string

	makeTarget string
	makeArgs   []string

	dryRun bool
}

func (c *Command) buildProject(projectPath string) error {
	commandArgs := []string{
		"-C",
		filepath.Join(c.gitRoot, "projects", projectPath),
	}
	allMakeTargets := strings.Split(c.makeTarget, ",")
	commandArgs = append(commandArgs, allMakeTargets...)
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
	return nil
}

func main() {
	target := flag.String("target", "release", "Make target")
	releaseBranch := flag.String("release-branch", "1-19", "Release branch to test")
	releaseVariant := flag.String("release-variant", "", "Release variant to test")
	release := flag.String("release", "1", "Release to test")
	region := flag.String("region", "us-west-2", "AWS region to use")
	accountId := flag.String("account-id", "", "AWS Account ID to use")
	imageRepo := flag.String("image-repo", "", "Container image repository")
	artifactBucket := flag.String("artifact-bucket", "", "S3 bucket for artifacts")
	gitRoot := flag.String("git-root", "", "Git root directory")
	dryRun := flag.Bool("dry-run", false, "Echo out commands, but don't run them")
	rebuildAll := flag.Bool("rebuild-all", false, "Rebuild all projects, regardless of changes present")
	buildKubeFirst := flag.Bool("build-kubernetes-first", true, "Build kubernetes projects first then other components")

	flag.Parse()
	log.Printf("Running postsubmit - dry-run: %t", *dryRun)

	c := &Command{
		releaseBranch:  *releaseBranch,
		releaseVariant: *releaseVariant,
		release:        *release,
		artifactBucket: *artifactBucket,
		gitRoot:        *gitRoot,
		makeTarget:     *target,
		dryRun:         *dryRun,
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
		fmt.Sprintf("AWS_REGION=%s", *region),
		fmt.Sprintf("AWS_ACCOUNT_ID=%s", *accountId),
		fmt.Sprintf("IMAGE_REPO=%s", *imageRepo),
	}

	cmd := exec.Command("git", "-C", c.gitRoot, "diff", "--name-only", "HEAD^", "HEAD")
	log.Printf("Executing command: %s", strings.Join(cmd.Args, " "))
	gitDiffOutput, err := cmd.Output()
	if err != nil {
		log.Fatalf("error running git diff: %v\n%s", err, string(gitDiffOutput))
	}
	filesChanged := strings.Fields(string(gitDiffOutput))

	allChanged := false
	buildOrderKube := []string{
		"kubernetes/release",
		"kubernetes/kubernetes",
		"kubernetes/cloud-provider-aws",
	}

	buildOrder := []string{
		"containernetworking/plugins",
		"coredns/coredns",
		"etcd-io/etcd",
		"kubernetes-sigs/aws-iam-authenticator",
	}

	if *buildKubeFirst {
		buildOrder = append(buildOrderKube[:], buildOrder...)
	} else {
		buildOrder = append(buildOrder[:], buildOrderKube...)
	}

	type changedStruct struct {
		changed bool
	}
	projects := make(map[string]*changedStruct)
	for _, projectPath := range buildOrder {
		projects[projectPath] = &changedStruct{}
	}

	if *rebuildAll {
		allChanged = true
	} else {
		for _, file := range filesChanged {
			for projectPath := range projects {
				if strings.Contains(file, projectPath) {
					projects[projectPath].changed = true
				}
			}
			r := regexp.MustCompile("^Makefile$|^Common.mk$|cmd/main_postsubmit.go|EKS_DISTRO_.*_TAG_FILE|^release/.*|^build/lib/.*")
			if r.MatchString(file) {
				allChanged = true
			}
		}
	}

	for _, projectPath := range buildOrder {
		if projects[projectPath].changed || allChanged {
			err = c.buildProject(projectPath)
			if err != nil {
				log.Fatalf("error building %s: %v", projectPath, err)
			}
		}
	}
}
