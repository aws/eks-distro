package main

import (
	. "../internal"
	. "./internal"
	"errors"
	"flag"
	"log"
	"os"
	"os/exec"
	"strings"
)

// Updates RELEASE number for dev and/or prod, depending on the values
// provided to the appropriate flags. If a failure is encounter,
// attempts to undo any changes to RELEASE.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	includeProd := *flag.Bool("includeProd", true, "If production RELEASE should be incremented")
	includeDev := *flag.Bool("includeDev", true, "If development RELEASE should be incremented")
	includePR := *flag.Bool("includePR", true, "If a PR should be opened for changed")
	isBot := flag.Bool("isBot", false, "If a PR is created by bot")

	flag.Parse()

	release, err := initializeRelease(includeProd, includeDev, *branch)
	if err != nil {
		log.Fatalf("Error initializing release values: %v", err)
	}

	var changedProdFilePaths []string
	var changedDevFilePaths []string

	if includeProd {
		numberPath := release.ProductionReleasePath
		changedProdFilePaths = append(changedProdFilePaths, numberPath)
		err = updateEnvironmentReleaseNumber(release.Number(), numberPath)
		if err != nil {
			cleanUpIfError(changedProdFilePaths)
			log.Fatalf("Error writing to prod RELEASE: %v", err)
		}
	}

	if includeDev {
		numberPath := release.DevelopmentReleasePath
		changedDevFilePaths = append(changedDevFilePaths, numberPath)
		err = updateEnvironmentReleaseNumber(release.Number(), numberPath)
		if err != nil {
			cleanUpIfError(append(changedDevFilePaths, changedProdFilePaths...))
			log.Fatalf("Error writing to dev RELEASE: %v", err)
		}
	}

	log.Printf("Successfully updated number for %d file(s)\n", len(changedDevFilePaths)+len(changedProdFilePaths))

	if includePR {
		if includeProd {
			if err = OpenProdPR(&release, changedProdFilePaths, *isBot); err != nil {
				log.Fatal(err)
			}
			log.Printf("Opened PRs for %s\n", strings.Join(changedProdFilePaths, " "))
		}

		if includeDev {
			if err = OpenDevPR(&release, changedDevFilePaths, *isBot); err != nil {
				log.Fatal(err)
			}
			log.Printf("Opened PRs for %s\n", strings.Join(changedDevFilePaths, " "))
		}
		log.Println("Successfully opened PRs for changed files")
	}
}

func initializeRelease(includeProd, includeDev bool, branch string) (Release, error) {
	if includeProd {
		return NewRelease(branch)
	} else if includeDev {
		return NewReleaseWithOverrideEnvironment(branch, Development)
	}
	return Release{},errors.New("cannot make release if no environment is indicated")
}

func updateEnvironmentReleaseNumber(number, numberFilePath string) error {
	if len(number) == 0 {
		return errors.New("failed to update release number file because provided number was empty")
	}
	return os.WriteFile(numberFilePath, []byte(number+"\n"), 0644)
}

func cleanUpIfError(paths []string) {
	log.Println("Encountered error so all attempting to restore files")

	for _, path := range paths {
		err := exec.Command("git", "restore", path).Run()
		if err == nil {
			log.Printf("If changes were made, restored %s", path)
		}
	}
	log.Println("Finished attempting to restore files")
}
