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
	isProd := flag.Bool("isProd", false, "True for prod; false for dev")
	includePR := flag.Bool("openPR", true, "If a PR should be opened for changed")

	flag.Parse()

	releaseEnvironment := func() ReleaseEnvironment {
		if *isProd {
			return Production
		}
		return Development
	}()

	releaseNumber, err := CreateReleaseNumber(*branch, releaseEnvironment)
	if err != nil {
		log.Fatalf("Error calculating %s RELEASE: %v", releaseEnvironment.String(), err)
	}

	err = updateEnvironmentReleaseNumber(releaseNumber)
	if err != nil {
		cleanUpIfError(releaseNumber.FilePath())
		log.Fatalf("Error writing to %s RELEASE: %v", releaseEnvironment.String(), err)
	}

	if *includePR {
		if err = OpenNumberPR(*branch, releaseNumber, releaseEnvironment); err != nil {
			log.Fatal(err)
		}
	}
}

func updateEnvironmentReleaseNumber(rn ReleaseNumber) error {
	if len(rn.Next()) == 0 {
		return errors.New("failed to update release number file because provided number was empty")
	}
	return os.WriteFile(rn.FilePath(), []byte(rn.Next()+"\n"), 0644)
}

func cleanUpIfError(path string) {
	log.Println("Encountered error so all attempting to restore file")
	err := exec.Command("git", "restore", path).Run()
	if err != nil {
		log.Printf("Encountered error while attempting to restored %s", path)
	} else {
		log.Printf("If changes were made, restored %s", path)
	}
}
