package main

import (
	"flag"
	"log"

	"github.com/aws/eks-distro/cmd/release/docs/existingdocs"
	"github.com/aws/eks-distro/cmd/release/docs/newdocs"
	"github.com/aws/eks-distro/cmd/release/utils"
	"github.com/aws/eks-distro/cmd/release/utils/changetype"
	"github.com/aws/eks-distro/cmd/release/utils/git"
	"github.com/aws/eks-distro/cmd/release/utils/values"
)

const changeType = changetype.Docs

// Generates docs for release. Value for 'branch' flag must be provided. The release MUST already be out, and all
// upstream changes MUST be pulled down locally.
// TODO: fix all logic around undoing changes if error.
func main() {
	branch := flag.String("branch", "", "Release branch, e.g. 1-23")
	flag.Parse()

	////////////	Create Release		////////////////////////////////////

	// The actual release MUST already be out, and all upstream changes MUST be pulled down locally.
	r, err := utils.NewRelease(*branch, changeType)
	if err != nil {
		log.Fatalf("creating new release: %v", err)
	}

	////////////	Create Git Manager	////////////////////////////////////

	gm, err := git.CreateGitManager(r.Branch(), r.Number(), changeType)
	if err != nil {
		log.Fatalf("creating new git manager: %v", err)
	}
	err = gm.AddAndCommit(changedFiles...)
	if err != nil {
		log.Fatalf("Failed to update doc due to error: %v", err)
	}

	////////////	Create new docs		////////////////////////////////////

	log.Println("Starting to create new docs")

	abandon := abandonFunc(gm)

	docs, err := newdocs.CreateNewDocsInput(r)
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
	if err = gm.AddAndCommitDirectory(*newDocsDir); err != nil {
		cleanUpDir()
		log.Fatalf("adding and committing new docs %q\n%v", newDocsDir, err)
	}
	log.Println("Finished creating new docs\n--------------------------")

	////////////	Update existing docs	////////////////////////////////////

	log.Println("Starting to update existing new docs")

	cleanUp := cleanUpFunc(gm)

	var existingDocsUpdateFuncs = map[values.AbsolutePath]func(*utils.Release, string) error{
		values.IndexPath:  existingdocs.UpdateDocsIndex,
		values.ReadmePath: existingdocs.UpdateREADME,
	}

	for ap, updateFunc := range existingDocsUpdateFuncs {
		log.Printf("Starting update of %v\n", ap)
		if err = updateFunc(r, ap.String()); err != nil {
			cleanUp(ap)
			log.Fatalf("updating %s: %v", ap, err)
		}
		if err = gm.AddAndCommit(ap); err != nil {
			cleanUp(ap)
			log.Fatalf("adding and committing %s after changes had been made: %v", ap, err)
		}
		log.Printf("Successfully updated %v\n", ap)
	}
	log.Println("Finished updating existing docs\n--------------------------")

	////////////	Open PR		////////////////////////////////////

	if err = gm.OpenPR(); err != nil {
		log.Fatalf("opening PR: %v", err)
	}

}

func abandonFunc(gm *git.Manager) func() {
	return func() {
		if abandonErr := gm.Abandon(); abandonErr != nil {
			log.Printf("encountered error while attemptng to abandon branch due to earlier error: %v", abandonErr)
		}
	}
}

func cleanUpDirFunc(gm *git.Manager, nd values.NewDirectory) func() {
	return func() {
		if cleanUpErr := gm.DeleteDirectoryAndAbandonAllChanges(&nd); cleanUpErr != nil {
			log.Printf("encountered an error while attemptng to clean up due to earlier error: %v", cleanUpErr)
		}
	}
}

func cleanUpFunc(gm *git.Manager) func(values.AbsolutePath) {
	return func(ap values.AbsolutePath) {
		cleanUpErrs := gm.RestoreFileAndAbandonAllChanges(ap)
		if len(cleanUpErrs) > 0 {
			log.Printf("encountered %d error(s) while attemptng to clean up due to earlier error: %v",
				len(cleanUpErrs), cleanUpErrs)
		}
	}
}
