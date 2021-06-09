package main

import (
	utils "../internal"
	. "./internal"
	"fmt"

	"flag"
	"log"
)

// Generate docs for release. Value for 'branch' flag much be provided.
// If a failure is encounter, attempts to undo any changes to files in branch doc directory, including deleting the
// directory if it was created.
// The 'overrideNumber' flag should not be used unless there is a very specific need to override expected behavior. Using
// this flag may result in errors or bugs in release number sequencing, which may not be apparent or easily identified.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")
	environment := flag.String("environment", "development", "Should be 'development' or 'production'")
	force := flag.Bool("force", true, "Forces the replacement of existing with generated")

	includeChangelog := *flag.Bool("includeChangelog", true, "If changelog should be generated")
	includeIndex := *flag.Bool("includeIndex", true, "If index in branch dir should be generated")
	includeIndexAppendedText := *flag.Bool("includeIndexAppendedText", true, "If Markdown table should be generated")
	includeAnnouncement := *flag.Bool("includeAnnouncement", true, "If release announcement should be generated")

	overrideNumber := flag.Int("overrideNumber", -1, "Overrides default logic for number, which is not recommended")

	flag.Parse()

	release, err := utils.NewReleaseWithOverrideNumber(*branch, *environment, *overrideNumber)
	if err != nil {
		log.Fatalf("Error initializing release values: %v", err)
	}

	includeDocs := include{
		changelog:         includeChangelog,
		index:             includeIndex,
		indexAppendedText: includeIndexAppendedText,
		announcement:      includeAnnouncement,
	}
	docs := createDocsInfo(&includeDocs, release.VBranchEKSNumber)

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
		log.Println("Finished attempting to undo all changes")
		log.Fatalf("Error that was encountered while writing to docs : %v", err)
	}

	DeleteDocsDirectoryIfEmpty(release)
	log.Printf("Finished writing to %v doc(s)\n", len(docStatuses))
}

type include struct {
	changelog, index, announcement bool
	indexAppendedText              bool
}

func createDocsInfo(includeDocs *include, formattedReleaseVersion string) []Doc {
	var indexAppendToEndFunc func(*utils.Release) (string, error)
	if includeDocs.indexAppendedText {
		indexAppendToEndFunc = GetComponentVersionsTable
	}
	return []Doc{
		{
			Filename:     fmt.Sprintf("CHANGELOG-%s.md", formattedReleaseVersion),
			TemplateName: ChangeLogBaseImage,
			IsIncluded:   includeDocs.changelog,
		},
		{
			Filename:     "index.md",
			TemplateName: IndexInBranch,
			IsIncluded:   includeDocs.index,
			AppendToEnd:  indexAppendToEndFunc,
		},
		{
			Filename:     "release-announcement.txt",
			TemplateName: ReleaseAnnouncement,
			IsIncluded:   includeDocs.announcement,
		},
	}
}
