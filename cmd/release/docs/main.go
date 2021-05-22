package main

import (
	utils "../internal"
	. "../release_manager"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"text/template"
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

// Generate docs for release
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	environment := flag.String("environment", "development", "Should be 'development' or 'production'")

	flag.Parse()

	release, err := InitializeRelease(&Input{branch: *branch, environment: *environment})
	if err != nil {
		log.Fatalf("Error initializing release values: %v", err)
	}

	releaseDocsPath := utils.FormatReleaseDocsDirectory(release)

	err = os.Mkdir(releaseDocsPath, 0777)
	if err != nil {
		log.Fatalf("Error creating release docs directory: %v", err)
	}

	t := template.Must(template.New("changeLogText").Parse(utils.ChangeLogBaseImage))
	f, err := os.Create(fmt.Sprintf(releaseDocsPath+"/CHANGELOG-%s.md", release.ReleaseTag))
	if err != nil {
		log.Fatalf("Error while creating changelog file: %v", err)
	}

	docsWriter := io.Writer(f)
	err = t.Execute(docsWriter, release)
	if err != nil {
		deleteDocsIfError(release)
		log.Fatalf("Error while writing to changelog file: %v", err)
	}

	log.Println("Successfully generated docs for " + release.ReleaseTag)
}

func deleteDocsIfError(release *Release) {
	log.Println("Encountered error so attempting to delete generated docs files")
	utils.DeleteDocsPath(release)
	log.Println("Finished attempting to delete generated doc files")
}
