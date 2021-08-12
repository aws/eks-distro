package main

import (
	. "../internal"
	. "./internal"
	"fmt"

	"flag"
	"log"
)

const skipOverrideNumber = -1

// Generate docs for release. Value for 'branch' flag much be provided.
// If a failure is encounter, attempts to undo any changes to files in branch doc directory, including deleting the
// directory if it was created.
// The 'overrideNumber' flag should not be used unless there is a very specific need to override expected behavior. Using
// this flag may result in errors or bugs in release number sequencing, which may not be apparent or easily identified.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")

	// Generate new files
	includeChangelog := *flag.Bool("includeChangelog", true, "If changelog should be generated")
	includeIndex := *flag.Bool("includeIndex", true, "If index in branch dir should be generated")
	includeIndexAppendedText := *flag.Bool("includeIndexAppendedText", true, "If Markdown table should be generated")
	includeAnnouncement := *flag.Bool("includeAnnouncement", true, "If release announcement should be generated")

	// Update existing files
	includeREADME := *flag.Bool("includeREADME", true, "If README should be updated")
	includeDocsIndex := *flag.Bool("includeDocsIndex", true, "If index.md in docs should be updated")

	openPR := *flag.Bool("openPR", true, "If a PR should be opened for changed")
	isBot := flag.Bool("isBot", false, "If a PR is created by bot")

	// Circumvent standard workflow. Use with caution!
	force := flag.Bool("force", false, "Forces the replacement of existing with generated")
	overrideNumber := flag.Int("overrideNumber", skipOverrideNumber, "Overrides default logic for number, which is not recommended")

	flag.Parse()

	release, err := initializeRelease(*branch, *overrideNumber)
	if err != nil {
		log.Fatalf("Error initializing release values: %v", err)
	}

	var docStatuses []DocStatus

	// Generate new files
	includeGeneratedDocs := includeGenerated{
		changelog:         includeChangelog,
		index:             includeIndex,
		indexAppendedText: includeIndexAppendedText,
		announcement:      includeAnnouncement,
	}
	generatedDocsInfo := createGeneratedDocsInfo(&includeGeneratedDocs, release.VBranchEKSNumber)

	docStatusesWriteToDocs, err := WriteToDocs(generatedDocsInfo, &release, *force)
	docStatuses = append(docStatuses, docStatusesWriteToDocs...)
	if err != nil {
		UndoChanges(docStatuses)
		DeleteDocsDirectoryIfEmpty(&release)
		log.Fatalf("Error that was encountered while writing to docs : %v", err)
	}

	// Update existing files
	if includeREADME {
		docStatusREADME, err := UpdateREADME(&release, *force)
		docStatuses = append(docStatuses, docStatusREADME)
		if err != nil {
			UndoChanges(docStatuses)
			DeleteDocsDirectoryIfEmpty(&release)
			log.Fatalf("Error that was encountered while updating README: %v", err)
		}
	}
	if includeDocsIndex {
		docStatusDocsIndex, err := UpdateDocsIndex(&release, *force)
		docStatuses = append(docStatuses, docStatusDocsIndex)
		if err != nil {
			UndoChanges(docStatuses)
			DeleteDocsDirectoryIfEmpty(&release)
			log.Fatalf("Error that was encountered while updating index: %v", err)
		}
	}

	DeleteDocsDirectoryIfEmpty(&release)
	log.Printf("Finished writing to %v doc(s)\n", len(docStatuses))

	if openPR {
		err = OpenDocsPR(&release, docStatuses, *isBot)
		if err != nil {
			log.Fatalf("error opending PR: %v", err)
		}
	}
}

func initializeRelease(branch string, overrideNumber int) (Release, error) {
	if overrideNumber == skipOverrideNumber {
		return NewRelease(branch)
	}
	return NewReleaseWithOverrideNumber(branch, overrideNumber)
}

type includeGenerated struct {
	changelog, index, announcement bool
	indexAppendedText              bool
}

func createGeneratedDocsInfo(includeGenerated *includeGenerated, formattedReleaseVersion string) []GeneratedDoc {
	var indexAppendToEndFunc func(*Release) (string, error)
	if includeGenerated.indexAppendedText {
		// Use 'GetComponentVersionsTable' to generate the table using the release manifest, which must exist.
		indexAppendToEndFunc = GetComponentVersionsTableIfNoReleaseManifest
	}
	return []GeneratedDoc{
		{
			Filename:     fmt.Sprintf("CHANGELOG-%s.md", formattedReleaseVersion),
			TemplateName: ChangeLogBaseImage,
			IsIncluded:   includeGenerated.changelog,
		},
		{
			Filename:     "index.md",
			TemplateName: IndexInBranch,
			IsIncluded:   includeGenerated.index,
			AppendToEnd:  indexAppendToEndFunc,
		},
		{
			Filename:     "release-announcement.txt",
			TemplateName: ReleaseAnnouncement,
			IsIncluded:   includeGenerated.announcement,
		},
	}
}
