package main

import (
	"flag"
	"log"
	"strconv"

	"github.com/aws/eks-distro/cmd/release/docs/existingdocs"
	"github.com/aws/eks-distro/cmd/release/docs/newdocs"
	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/git"
	"github.com/aws/eks-distro/cmd/release/utils/release"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

const changeType = changetype.Docs

// Generates docs for release. The release MUST already be out, and all upstream changes MUST be pulled down locally.
// Value for 'branch' flag must be provided. Value for 'hasChangelogChanges' flag should be 'false' if auto-
// generating the changes in the changelog will cause an error.
// TODO: fix the hacky code related to opening PRs and git commands. It is bad, and I am sorry.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-23")
	hasManageGitAndPR := flag.Bool("manageGitAndOpenPR", true, "If PR and all git should be done")
	hasReleaseAnnouncement := flag.Bool("releaseAnnouncement", true, "If changes in changelog should be generated")
	overrideNumber := flag.Int("optionalOverrideNumber", release.InvalidNumberUpperLimit,
		"USE WITH CAUTION! Value to force override for number. Any value less than or equal to "+
			strconv.Itoa(release.InvalidNumberUpperLimit)+" is considered an indication that the number should not be overridden.")
	flag.Parse()

	////////////	Create Release		////////////////////////////////////

	// The actual release MUST already be out, and all upstream changes MUST be pulled down locally.
	r, err := func(overrideNum int, branch *string) (*release.Release, error) {
		if overrideNum > release.InvalidNumberUpperLimit {
			return release.NewReleaseOverrideNumber(*branch, strconv.Itoa(overrideNum))
		} else {
			return release.NewRelease(*branch, changeType)
		}
	}(*overrideNumber, branch)

	////////////	Create Git Manager	////////////////////////////////////

	var gm *git.Manager
	if *hasManageGitAndPR {
		gm, err = git.CreateGitManager(r.Branch(), r.Number(), changeType)
		if err != nil {
			log.Fatalf("creating new git manager: %v", err)
		}
	}

	////////////	Create new docs		////////////////////////////////////

	log.Println("Starting to create new docs")

	abandon := abandonFunc(gm)

	docs, err := newdocs.CreateNewDocsInput(r, *hasReleaseAnnouncement)

	if err != nil {
		abandon()
		log.Fatalf("creating new docs input: %v", err)
	}

	newDocsDir, err := values.MakeNewDirectory(values.GetReleaseDocsDirectory(r))
	if err != nil {
		abandon()
		log.Fatalf("creating new directory for release docs: %v", err)
	}

	cleanUpDir := cleanUpDirFunc(gm, *newDocsDir)

	if err = newdocs.GenerateNewDocs(docs, *newDocsDir); err != nil {
		cleanUpDir()
		log.Fatalf("creating new docs: %v", err)
	}
	if *hasManageGitAndPR {
		if err = gm.AddAndCommitDirectory(*newDocsDir); err != nil {
			cleanUpDir()
			log.Fatalf("adding and committing new docs %q\n%v", newDocsDir, err)
		}
	}
	log.Println("Finished creating new docs\n--------------------------")

	////////////	Update existing docs	////////////////////////////////////

	log.Println("Starting to update existing new docs")

	cleanUp := cleanUpFunc(gm)

	var existingDocsUpdateFuncs = map[values.AbsolutePath]func(*release.Release, string) error{
		values.IndexPath:  existingdocs.UpdateDocsIndex,
		values.ReadmePath: existingdocs.UpdateREADME,
	}

	for ap, updateFunc := range existingDocsUpdateFuncs {
		log.Printf("Starting update of %v\n", ap)
		if err = updateFunc(r, ap.String()); err != nil {
			cleanUp(ap)
			log.Fatalf("updating %s: %v", ap, err)
		}
		if *hasManageGitAndPR {
			if err = gm.AddAndCommit(ap); err != nil {
				cleanUp(ap)
				log.Fatalf("adding and committing %s after changes had been made: %v", ap, err)
			}
		}
		log.Printf("Successfully updated %v\n", ap)
	}
	log.Println("Finished updating existing docs\n--------------------------")

	////////////	Open PR		////////////////////////////////////

	if *hasManageGitAndPR {
		if err = gm.OpenPR(); err != nil {
			log.Fatalf("opening PR: %v", err)
		}
	}

}

func abandonFunc(gm *git.Manager) func() {
	if gm == nil {
		return func() {}
	}
	return func() {
		if abandonErr := gm.Abandon(); abandonErr != nil {
			log.Printf("encountered error while attemptng to abandon branch due to earlier error: %v", abandonErr)
		}
	}
}

func cleanUpDirFunc(gm *git.Manager, nd values.NewDirectory) func() {
	if gm == nil {
		return func() {}
	}
	return func() {
		if cleanUpErr := gm.DeleteDirectoryAndAbandonAllChanges(&nd); cleanUpErr != nil {
			log.Printf("encountered an error while attemptng to clean up due to earlier error: %v", cleanUpErr)
		}
	}
}

func cleanUpFunc(gm *git.Manager) func(values.AbsolutePath) {
	if gm == nil {
		return func(values.AbsolutePath) {}
	}
	return func(ap values.AbsolutePath) {
		cleanUpErrs := gm.RestoreFileAndAbandonAllChanges(ap)
		if len(cleanUpErrs) > 0 {
			log.Printf("encountered %d error(s) while attemptng to clean up due to earlier error: %v",
				len(cleanUpErrs), cleanUpErrs)
		}
	}
}
