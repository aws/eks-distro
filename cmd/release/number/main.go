package main

import (
	"errors"
	"flag"
	"log"
	"os"

	"github.com/aws/eks-distro/cmd/release/utils"
	"github.com/aws/eks-distro/cmd/release/utils/git_manager"
)

// Updates RELEASE number for dev or prod, depending on the values provided to the appropriate flags.
// TODO: fix all logic around undoing changes if error.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	isProd := flag.Bool("isProd", false, "True for prod; false for dev")

	flag.Parse()

	environment := func() utils.ChangesType {
		if *isProd {
			return utils.Prod
		}
		return utils.Dev
	}()

	nextNumber, numberFilePath, err := utils.GetNextNumber(*branch, environment)
	if err != nil {
		log.Fatalf("calculating %s RELEASE: %v", environment, err)
	}

	gitManager, err := git_manager.CreateGitManager(*branch, nextNumber, environment)
	if err != nil {
		log.Fatalf("creating git manager for %s RELEASE: %v", environment, err)
	}

	if err = updateEnvironmentReleaseNumber(nextNumber, numberFilePath); err != nil {
		cleanUpIfError(gitManager, numberFilePath)
		log.Fatalf("writing to %s RELEASE: %v", environment, err)
	}

	if err = gitManager.AddAndCommit(numberFilePath); err != nil {
		cleanUpIfError(gitManager, numberFilePath)
		log.Fatalf("adding and committing: %v", err)
	}

	if err = gitManager.OpenPR(); err != nil {
		log.Fatalf("adding and committing: %v", err)
	}
}

func updateEnvironmentReleaseNumber(number, numberFilPath string) error {
	if len(number) == 0 {
		return errors.New("updating release number file because provided number was empty")
	}
	return os.WriteFile(numberFilPath, []byte(number+"\n"), 0644)
}

func cleanUpIfError(gm *git_manager.GitManager, filepath string) {
	restoreErr := gm.RestoreFile(filepath)
	if restoreErr != nil {
		log.Printf("Encountered error while attempting to restored %s", filepath)
	} else {
		log.Println("Encountered error so restored file")
	}
	gm.AbandonBranch()
}
