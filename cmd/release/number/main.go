package main

import (
	utils "../internal"
	"errors"

	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
)

// Updates RELEASE and KUBE_GIT_VERSION
// If a failure is encounter, attempts to undo any changes to RELEASE and KUBE_GIT_VERSION.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	environment := flag.String("environment", "development", "Should be 'development' or 'production'")

	flag.Parse()

	release, err := utils.NewRelease(*branch, *environment)
	if err != nil {
		log.Fatalf("Error initializing release values: %v", err)
	}

	err = updateEnvironmentReleaseNumber(release)
	if err != nil {
		cleanUpIfError(release)
		log.Fatalf("Error writing to RELEASE: %v", err)
	}

	err = updateKubeGitVersionFile(release)
	if err != nil {
		cleanUpIfError(release)
		log.Fatalf("Error updating KUBE_GIT_VERSION: %v", err)
	}

	log.Println("Successfully updated release number for " + release.EKSBranchNumber)
}

func updateEnvironmentReleaseNumber(release *utils.Release) error {
	releaseNumber := release.Number()
	if len(releaseNumber) == 0 {
		return errors.New("failed to update release number file because provided number was empty")
	}
	return os.WriteFile(release.EnvironmentReleasePath, []byte(releaseNumber+"\n"), 0644)
}

func updateKubeGitVersionFile(release *utils.Release) error {
	if len(release.EKSBranchPreviousNumber) == 0 {
		return errors.New("failed to update KUBE_GIT_VERSION because previous release version tag is empty")
	}
	if len(release.EKSBranchNumber) == 0 {
		return errors.New("failed to update KUBE_GIT_VERSION because release version tag is empty")
	}

	kubeGitVersionFilePath := release.KubeGitVersionFilePath
	data, err := ioutil.ReadFile(kubeGitVersionFilePath)
	if err != nil {
		return fmt.Errorf("failed to read file because error: %v", err)
	}

	linebreak := []byte("\n")
	splitData := bytes.Split(data, linebreak)

	prefix := []byte("KUBE_GIT_VERSION='")
	hasFoundPrefix := false

	for i, line := range splitData {
		if !bytes.HasPrefix(line, prefix) {
			continue
		}
		hasFoundPrefix = true

		// End of line character (') is included to ensure entire version tag is captured
		versionTagToEndOfLine := []byte(release.EKSBranchNumber + "'")
		if bytes.Contains(line, versionTagToEndOfLine) {
			log.Printf("version tag %q already set", release.EKSBranchNumber)
			return nil
		}

		prevVersionTagToEndOfLine := []byte(release.EKSBranchPreviousNumber + "'")
		if !bytes.Contains(line, prevVersionTagToEndOfLine) {
			return fmt.Errorf("fail to find previous version tag %q to replace", release.EKSBranchPreviousNumber)
		}

		splitData[i] = bytes.Replace(line, prevVersionTagToEndOfLine, versionTagToEndOfLine, 1)
		break
	}

	if !hasFoundPrefix {
		return fmt.Errorf("failed to find line starting with %q that is needed to update version tag", prefix)
	}
	return os.WriteFile(kubeGitVersionFilePath, bytes.Join(splitData, linebreak), 0644)
}

func cleanUpIfError(release *utils.Release) {
	log.Println("Encountered error so all attempting to restore files")

	paths := []string{
		release.EnvironmentReleasePath,
		release.KubeGitVersionFilePath,
	}

	for _, path := range paths {
		err := exec.Command("git", "restore", path).Run()
		if err == nil {
			log.Printf("If changes were made, restored %s", path)
		}
	}
	log.Println("Finished attempting to restore files")
}
