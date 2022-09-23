package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/git"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

// Updates RELEASE number for dev or prod, depending on the values provided to the appropriate flags.
// TODO: fix all logic around undoing changes if error.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	isProd := flag.Bool("isProd", false, "True for prod; false for dev")

	flag.Parse()

	environment := func() changetype.ChangeType {
		if *isProd {
			return changetype.Prod
		}
		return changetype.Dev
	}()

	nextNumber, numberFilePath, err := getNextNumber(*branch, environment)
	if err != nil {
		log.Fatalf("calculating %s RELEASE: %v", environment, err)
	}

	gm, err := git.CreateGitManager(*branch, nextNumber, environment)
	if err != nil {
		log.Fatalf("creating git manager for %s RELEASE: %v", environment, err)
	}

	if err = updateEnvironmentReleaseNumber(nextNumber, numberFilePath); err != nil {
		cleanUpErrs := gm.RestoreFileAndAbandonAllChanges(numberFilePath)
		if len(cleanUpErrs) > 0 {
			log.Printf("encountered %d error(s) while attemptng to clean up due to earlier error: %v",
				len(cleanUpErrs), cleanUpErrs)
		}
		log.Fatalf("writing to %s RELEASE: %v", environment, err)
	}

	if err = gm.AddAndCommit(numberFilePath); err != nil {
		cleanUpErrs := gm.RestoreFileAndAbandonAllChanges(numberFilePath)
		if len(cleanUpErrs) > 0 {
			log.Printf("encountered %d error(s) while attemptng to clean up due to earlier error: %v",
				len(cleanUpErrs), cleanUpErrs)
		}
		log.Fatalf("adding and committing: %v", err)
	}

	if err = gm.OpenPR(); err != nil {
		log.Fatalf("adding and committing: %v", err)
	}
}

// getNextNumber returns the next number and the filepath to the local file for the current number used to determine
// the next number.
func getNextNumber(branch string, ct changetype.ChangeType) (nextNum string, numPath values.AbsolutePath, err error) {
	currNum, numPath, err := values.GetLocalNumber(branch, ct)
	if err != nil {
		return "", "", fmt.Errorf("getting local number: %w", err)
	}

	currNumAsInt, err := strconv.Atoi(currNum)
	if err != nil {
		return "", "", fmt.Errorf("calculating next number from current number %s: %w", currNum, err)
	}
	return strconv.Itoa(currNumAsInt + 1), numPath, nil
}

func updateEnvironmentReleaseNumber(number string, numberFilPath values.AbsolutePath) error {
	if len(number) == 0 {
		return fmt.Errorf("updating release number file %s because provided number was empty", numberFilPath)
	}
	return os.WriteFile(numberFilPath.String(), []byte(number+"\n"), 0644)
}
