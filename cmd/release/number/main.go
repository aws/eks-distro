package main

import (
	. "github.com/aws/eks-distro/cmd/release/utils"
	. "github.com/aws/eks-distro/cmd/release/utils/git_manager"

	"errors"
	"flag"
	"log"
	"os"
)

// Updates RELEASE number for dev or prod, depending on the values provided to the appropriate flags.
// TODO: fix all logic around undoing changes if error.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	isProd := flag.Bool("isProd", false, "True for prod; false for dev")

	flag.Parse()

	environment := func() ChangesType {
		if *isProd {
			return Prod
		}
		return Dev
	}()

	nextNumber, numberFilePath, err := GetNextNumber(*branch, environment)
	if err != nil {
		log.Fatalf("Error calculating %s RELEASE: %v", environment, err)
	}

	gitManager, err := CreateGitManager(*branch, nextNumber, environment)
	if err != nil {
		log.Fatalf("Error creating git manager for %s RELEASE: %v", environment, err)
	}

	if err = updateEnvironmentReleaseNumber(nextNumber, numberFilePath); err != nil {
		cleanUpIfError(gitManager, numberFilePath)
		log.Fatalf("Error writing to %s RELEASE: %v", environment, err)
	}

	if err = gitManager.AddAndCommit(numberFilePath); err != nil {
		cleanUpIfError(gitManager, numberFilePath)
		log.Fatalf("error adding and committing: %v", err)
	}

	if err = gitManager.OpenPR(); err != nil {
		log.Fatalf("error adding and committing: %v", err)
	}
}

func updateEnvironmentReleaseNumber(number, numberFilPath string) error {
	if len(number) == 0 {
		return errors.New("failed to update release number file because provided number was empty")
	}
	return os.WriteFile(numberFilPath, []byte(number+"\n"), 0644)
}

func cleanUpIfError(gm *GitManager, filepath string) {
	restoreErr := gm.RestoreFile(filepath)
	if restoreErr != nil {
		log.Printf("Encountered error while attempting to restored %s", filepath)
	} else {
		log.Println("Encountered error so restored file")
	}
	gm.AbandonBranch()
}
