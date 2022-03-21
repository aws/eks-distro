package main

import (
	. "./existing_docs"
	. "./internal"
	. "./new_docs"
	. "./new_docs/templates"
	"fmt"

	"flag"
	"log"
)

const skipOverrideNumber = -1

/*
Generate docs for release. Value for 'branch' flag must be provided.

If a failure is encounter, attempts to undo any changes to files in branch doc directory, including deleting the
directory if it was created.

Caution about specific flags

	usePrevReleaseManifestForComponentTable

		If false, there if no guarantee that the generated table is correct for that release, as the generated table is
		based on the previous release's release manifest (which must exist).

		If true, the release manifest for that release must exist.

	isLocalReleaseNumberForNewRelease

		If false, the local prod release number of the branch must be from the current release number, which will be
		incremented for the next release. The generated docs are for the next release.

		If true, the local prod release number of the branch must be the new release number. Typically, this means an
		earlier PR incremented the release number, the PR was merged, and the change was pulled down locally. The
		generated docs are for this release

	overrideNumber and force

		Both flags undercut the logical bedrock of the doc generation: the release number. The release number's impact
		extends far beyond what is discernible by looking at the docs. Factors well outside the scope of this command,
		such as the passage of time or code changes unrelated to the release, impact the generation of docs in
		critically important ways that are not readily apparent.

		Circumventing the expected and established workflow can easily result in errors that are not easily identifiable
		or consistent throughout the docs. Executing a command without an error does not mean that there are no errors
		in the generated docs. Even if a command with these flags produces error-free docs one time, there is no
		guarantee that rerunning the same command will still generate error-free docs.

		If overrideNumber is used, isLocalReleaseNumberForNewRelease is ignored.
*/
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-20")

	// TODO: add flag for only base image updates and pick templates accordingly
	// Generate new files
	includeChangelog := flag.Bool("includeChangelog", true, "If changelog should be generated")
	includeAnnouncement := flag.Bool("includeAnnouncement", true, "If release announcement should be generated")
	includeIndex := flag.Bool("includeIndex", true, "If index in branch dir should be generated")
	includeIndexComponentTable := flag.Bool("includeIndexComponentTable", true, "If Markdown table should be generated. Ignored if includeIndex is false.")
	usePrevReleaseManifestForComponentTable := flag.Bool("usePrevReleaseManifestForComponentTable", true, "If Markdown table should be generated from release manifest, which must exist if .")
	isLocalReleaseNumberForNewRelease := flag.Bool("isLocalReleaseNumberForNewRelease", true, "TODO")

	// Update existing files
	includeREADME := flag.Bool("includeREADME", true, "If README should be updated")
	includeDocsIndex := flag.Bool("includeDocsIndex", true, "If index.md in docs should be updated")

	openPR := flag.Bool("openPR", true, "If a PR should be opened for changed")

	// WARNING: use of these flags can produce errors that are not easily identifiable. See comment at top.
	force := flag.Bool("force", false, "Replaces existing files with newly-generated ones")
	overrideNumber := flag.Int("overrideNumber", skipOverrideNumber, "Overrides default logic for number, which is not recommended")

	flag.Parse()

	release, err := initializeRelease(*branch, *overrideNumber, *isLocalReleaseNumberForNewRelease)
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

	docStatusesForNewDocs, err := GenerateNewDocs(generatedDocsInfo, &release, *force)
	docStatuses = append(docStatuses, docStatusesForNewDocs...)
	if err != nil {
		UndoChanges(docStatuses)
		DeleteDocsDirectoryIfEmpty(&release)
		log.Fatalf("Error that was encountered while creating new docs: %v", err)
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

	if *openPR {
		err = OpenDocsPR(&release, docStatuses)
		if err != nil {
			log.Fatalf("error opening PR: %v", err)
		}
	}
}

func initializeRelease(branch string, overrideNumber int, isLocalReleaseNumberForNewRelease bool) (Release, error) {
	if overrideNumber == skipOverrideNumber {
		return NewRelease(branch, isLocalReleaseNumberForNewRelease)
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
			TemplateName: ChangeLogGenericBase,
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
			TemplateName: ReleaseAnnouncementGenericBase,
			IsIncluded:   includeGenerated.announcement,
		},
	}
}
