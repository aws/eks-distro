package main

import (
	. "../internal"
	. "./internal"
	"fmt"

	"flag"
	"log"
)

const skipOverrideNumber = -1

/*
Generate docs for release. Value for 'branch' flag must be provided.

If a failure is encounter, attempts to undo any changes to files in branch doc directory, including deleting the
directory if it was created.


Assumptions if using default flag value:

  - The new release is only for a base image update. Future plans are to provide more options.
  - The release number in the local code has not been incremented yet for the new release, and the generated doc should
	be for the new release. The new release number is the release number in the local code one incremented by 1.
  - The new release is using the same component versions in the preceding version's release manifest, and the preceding
	version's release manifest does not contain errors and follows the expected version naming convention.
  - Since the last release went out, there have been no code changes to the patches or component versions.
  - The production release will be cut today.


Caution about specific flags

  - usePrevReleaseManifestForComponentTable

		If false, there if no guarantee that the generated table is correct for that release, as the generated table is
		based on the previous release's release manifest (which must exist). However, if all the assumptions if using
		default flag values (see list above) are followed, one can be reasonably confident the table is correct.

		If true, the release manifest for that release must exist. If using a release's own release manifest, one can be
		reasonably confident the table is correct.

  - overrideNumber and force

		Both flags undercut the logical bedrock upon which all aspects of the generated docs depend: the release number.
		The release number's impact extends far beyond what is discernible by looking at the docs. Factors well outside
		of the scope of this command, such as the passage of time or code changes unrelated to the release, impact the
		generation of docs in critically important ways that are not readily apparent.

		Circumventing the expected and established workflow can easily result in errors that are not easily identifiable
		or consistent throughout the docs. Executing a command without an error does not mean that there are no errors
		in the generated docs.

		Even if a command with these flags produces error-free docs one time, there is no guarantee that rerunning the
		same command will still generate error-free docs.
*/
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")

	// Generate new files
	includeChangelog := flag.Bool("includeChangelog", true, "If changelog should be generated")
	includeAnnouncement := flag.Bool("includeAnnouncement", true, "If release announcement should be generated")
	includeIndex := flag.Bool("includeIndex", true, "If index in branch dir should be generated")
	includeIndexComponentTable := flag.Bool("includeIndexComponentTable", true, "If Markdown table should be generated. Ignored if includeIndex is false.")
	usePrevReleaseManifestForComponentTable := flag.Bool("usePrevReleaseManifestForComponentTable", true, "If Markdown table should be generated from release manifest, which must exist if .")

	// Update existing files
	includeREADME := flag.Bool("includeREADME", true, "If README should be updated")
	includeDocsIndex := flag.Bool("includeDocsIndex", true, "If index.md in docs should be updated")

	openPR := flag.Bool("openPR", true, "If a PR should be opened for changed")
	isBot := flag.Bool("isBot", false, "If a PR is created by bot")

	// WARNING: use of these flags can produce errors that are not easily identifiable. See comment at top.
	force := flag.Bool("force", false, "Replaces existing files with newly-generated ones")
	overrideNumber := flag.Int("overrideNumber", skipOverrideNumber, "Overrides default logic for number, which is not recommended")

	flag.Parse()

	release, err := initializeRelease(*branch, *overrideNumber)
	if err != nil {
		log.Fatalf("Error initializing release values: %v", err)
	}

	var docStatuses []DocStatus

	// Generate new files
	includeGeneratedDocs := includeGenerated{
		changelog:    *includeChangelog,
		announcement: *includeAnnouncement,
		index:        *includeIndex,
		indexComponentTableFunc: getComponentTableFunc(
			*includeIndex && *includeIndexComponentTable, *usePrevReleaseManifestForComponentTable,
		),
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
	if *includeREADME {
		docStatusREADME, err := UpdateREADME(&release, *force)
		docStatuses = append(docStatuses, docStatusREADME)
		if err != nil {
			UndoChanges(docStatuses)
			DeleteDocsDirectoryIfEmpty(&release)
			log.Fatalf("Error that was encountered while updating README: %v", err)
		}
	}
	if *includeDocsIndex {
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

	fmt.Printf("OPEN PR: %v\n\n", *openPR)
	if *openPR {
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

func getComponentTableFunc(includeComponentTable, usePrevRelease bool) func(*Release) (string, error) {
	if includeComponentTable {
		if usePrevRelease {
			return GetComponentVersionsTableIfNoReleaseManifest
		}
		return GetComponentVersionsTable
	}
	return nil
}

type includeGenerated struct {
	changelog, index, announcement bool
	indexComponentTableFunc        func(*Release) (string, error)
}

func createGeneratedDocsInfo(includeGenerated *includeGenerated, formattedReleaseVersion string) []GeneratedDoc {
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
			AppendToEnd:  includeGenerated.indexComponentTableFunc,
		},
		{
			Filename:     "release-announcement.txt",
			TemplateName: ReleaseAnnouncement,
			IsIncluded:   includeGenerated.announcement,
		},
	}
}
