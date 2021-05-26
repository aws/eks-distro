package main

import (
	utils "../internal"
	. "./internal"

	"flag"
	"fmt"
	"log"
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
	includeChangelog := flag.Bool("includeChangelog", true, "If changelog should be generated")
	includeBranchIndex := flag.Bool("includeBranchIndex", true, "If index in branch dir should be generated")
	includeAnnouncement := flag.Bool("includeAnnouncement", true, "If release announcement should be generated")
	force := flag.Bool("force", false, "Forces the replacement of existing with generated")

	flag.Parse()

	release, err := utils.InitializeRelease(&Input{branch: *branch, environment: *environment})
	if err != nil {
		log.Fatalf("Error initializing release values: %v", err)
	}

	docs := []Doc{
		{
			Filename:        fmt.Sprintf("CHANGELOG-%s.md", release.V_Branch_EKS_Number),
			TemplateName:    ChangeLogBaseImage,
			IsToBeWrittenTo: *includeChangelog,
		},
		{
			Filename:        "index.md",
			TemplateName:    IndexInBranch,
			IsToBeWrittenTo: *includeBranchIndex,
		},
		{
			Filename:        "release-announcement.txt",
			TemplateName:    ReleaseAnnouncement,
			IsToBeWrittenTo: *includeAnnouncement,
		},
	}

	docStatuses, err := WriteToDocs(docs, release, *force)
	if err != nil {
		log.Println("Encountered error while writing to docs. Attempting to undo all changes... ")
		for _, ds := range docStatuses {
			errForUndo := ds.UndoChanges()
			if errForUndo != nil {
				log.Printf("Error attempting to undo change: %v\n", errForUndo)
			}
		}
		DeleteDocsDirectoryIfEmpty(release)
		log.Println("Finished attempting to undo all changes\n")
		log.Fatalf("Error that was encountered while writing to docs : %v", err)
	}

	DeleteDocsDirectoryIfEmpty(release)
	log.Printf("Finished writing to %v doc(s)\n", len(docStatuses))
}
