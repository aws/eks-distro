package main

import (
	utils "../internal"
	. "../release_manager"
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

type Input struct {
	branch      string
	environment string
}

func (input Input) GetBranch() string {
	return input.branch
}

func (input Input) GetEnvironment() string {
	return input.environment
}

// Updates RELEASE and KUBE_GIT_VERSION
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	environment := flag.String("environment", "development", "Should be 'development' or 'production'")

	flag.Parse()

	release, err := InitializeRelease(&Input{branch: *branch, environment: *environment})
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

	log.Println("Successfully release number for " + release.VersionTag)
}

func updateEnvironmentReleaseNumber(release *Release) error {
	if len(release.Number) == 0 {
		return fmt.Errorf("failed to update release number file because provided number was empty")
	}
	return os.WriteFile(release.EnvironmentReleasePath, []byte(release.Number+"\n"), 0644)
}

func updateKubeGitVersionFile(release *Release) error {
	if len(release.PreviousVersionTag) == 0 {
		return fmt.Errorf("failed to update KUBE_GIT_VERSION because previous release version tag is empty")
	}
	if len(release.VersionTag) == 0 {
		return fmt.Errorf("failed to update KUBE_GIT_VERSION because release version tag is empty")
	}

	kubeGitVersionFilePath := utils.FormatKubeGitVersionFilePath(release)
	data, err := ioutil.ReadFile(kubeGitVersionFilePath)
	if err != nil {
		return fmt.Errorf("failed to read file because error: %v", err)
	}

	linebreak := []byte("\n")

	splitData := bytes.Split(data, linebreak)

	prefix := []byte("KUBE_GIT_VERSION='")
	foundPrefix := false

	for i, line := range splitData {
		if bytes.HasPrefix(line, prefix) {
			foundPrefix = true

			// End of line character (') is included to ensure entire version tag is captured
			versionTagToEndOfLine := []byte(release.VersionTag + "'")
			if bytes.Contains(line, versionTagToEndOfLine) {
				log.Printf("version tag %q already set", release.VersionTag)
				return nil
			}

			prevVersionTagToEndOfLine := []byte(release.PreviousVersionTag + "'")
			if !bytes.Contains(line, prevVersionTagToEndOfLine) {
				return fmt.Errorf("fail to find previous version tag %q to replace", release.PreviousVersionTag)
			}

			splitData[i] = bytes.Replace(line, prevVersionTagToEndOfLine, versionTagToEndOfLine, 1)
			break
		}
	}

	if !foundPrefix {
		return fmt.Errorf("failed to find line starting with %q that is needed to update version tag", prefix)
	}

	return os.WriteFile(kubeGitVersionFilePath, bytes.Join(splitData, linebreak), 0644)
}

func cleanUpIfError(release *Release) {
	log.Println("Encountered error so all attempting to restore files")
	utils.RestoreFilePath(release)
	log.Println("Finished attempting to restore files")
}
