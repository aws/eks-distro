package main

import (
	. "../utils"
	. "./internal"
	"errors"
	"flag"
	"log"
	"os"
	"os/exec"
)

// Updates RELEASE number for dev and/or prod, depending on the values
// provided to the appropriate flags. If a failure is encounter,
// attempts to undo any changes to RELEASE.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	includeProd := *flag.Bool("includeProd", true, "If production RELEASE should be incremented")
	includeDev := *flag.Bool("includeDev", true, "If development RELEASE should be incremented")
	includePR := *flag.Bool("openPR", true, "If a PR should be opened for changed")
	isBot := flag.Bool("isBot", false, "If a PR is created by bot")
	//openPR := flag.Bool("openPR", true, "If a PR should be opened for changed")

	flag.Parse()

	var changedProdFilePaths, changedDevFilePaths []string
	var prodReleaseNumber, devReleaseNumber ReleaseNumber
	var err error

	if includeProd {
		prodReleaseNumber, err = CreateReleaseNumber(*branch, Production)
		if err != nil {
			log.Fatalf("Error calculating prod RELEASE: %v", err)
		}

		changedProdFilePaths = append(changedProdFilePaths, prodReleaseNumber.FilePath())
		err = updateEnvironmentReleaseNumber(prodReleaseNumber)
		if err != nil {
			cleanUpIfError(changedProdFilePaths)
			log.Fatalf("Error writing to prod RELEASE: %v", err)
		}
	}

	if includeDev {
		devReleaseNumber, err = CreateReleaseNumber(*branch, Development)
		if err != nil {
			log.Fatalf("Error calculating dev RELEASE: %v", err)
		}

		changedDevFilePaths = append(changedDevFilePaths, devReleaseNumber.FilePath())
		err = updateEnvironmentReleaseNumber(devReleaseNumber)
		if err != nil {
			cleanUpIfError(append(changedDevFilePaths, changedProdFilePaths...))
			log.Fatalf("Error writing to dev RELEASE: %v", err)
		}
	}

	log.Printf("Successfully updated number for %d file(s)\n", len(changedDevFilePaths)+len(changedProdFilePaths))

	if includePR {
		if includeProd {
			if err = OpenNumberPR(*branch, prodReleaseNumber.Next(), changedProdFilePaths, *isBot, Production); err != nil {
				log.Fatal(err)
			}
		}

		if includeDev {
			if err = OpenNumberPR(*branch, devReleaseNumber.Next(), changedDevFilePaths, *isBot, Development); err != nil {
				log.Fatal(err)
			}
		}
		log.Println("Successfully opened PRs for changed files")
	}
}

func updateEnvironmentReleaseNumber(rn ReleaseNumber) error {
	if len(rn.Next()) == 0 {
		return errors.New("failed to update release number file because provided number was empty")
	}
	return os.WriteFile(rn.FilePath(), []byte(rn.Next()+"\n"), 0644)
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
