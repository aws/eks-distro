package internal

import (
	"errors"
	"fmt"
	"io/fs"
	"log"
	"os"
	"os/exec"
	"strings"
)

type DocStatus struct {
	path              string
	isAlreadyExisting bool
}

func InitializeDocStatus(filePath string) (DocStatus, error) {
	var isExistingFile bool
	
	_, err := os.Stat(filePath)
	if os.IsNotExist(err) {
		isExistingFile = false
	} else if err == nil {
		isExistingFile = true
	} else {
		return DocStatus{}, fmt.Errorf("encountered error checking file: %v", err)
	}
	return DocStatus{path: filePath, isAlreadyExisting: isExistingFile}, nil
		//if overrideIfExisting {
		//	fmt.Printf("file %v already exists but ignoring error because force option\n", filePath)
		//} else {
		//	return DocStatus{}, fmt.Errorf("file %v already exists and override option not enabled", filePath)
		//}

}

func UndoChanges(docStatuses []DocStatus) {
	log.Println("Encountered error processing docs. Attempting to undo all changes... ")
	for _, ds := range docStatuses {
		errForUndo := ds.undoChanges()
		if errForUndo != nil {
			log.Printf("Error attempting to undo change: %v\n", errForUndo)
		}
	}
	log.Println("Finished attempting to undo all changes")
}

func (docStatus *DocStatus) undoChanges() error {
	if docStatus.isEmpty() {
		return nil
	}

	docPath := docStatus.path

	_, err := os.Stat(docPath)
	if err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			log.Printf("Did not delete file because it does not exist: %s", docPath)
			return nil
		}
		return fmt.Errorf("failed to delete file because encountered error: %v", err)
	}

	if docStatus.isAlreadyExisting {
		err := exec.Command("git", "ls-files", "--error-unmatch", docPath).Run()
		if err != nil && strings.Compare(err.Error(), "exit status 1") == 0 {
			return fmt.Errorf("unable to restore existing file %v because it is not known to git", docPath)
		}

		err = exec.Command("git", "restore", docPath).Run()
		if err != nil {
			return fmt.Errorf("encountered error when attempting to restore file: %v", err)
		}

		log.Printf("Restored file %s to last git state", docPath)
		return nil

	} else {
		err := exec.Command("rm", "-rf", docPath).Run()
		if err != nil {
			return fmt.Errorf("encountered error when attempting to delete file: %v", err)
		}

		log.Printf("Deleted newly-created file %s", docPath)
		return nil
	}
}

func GetEmptyDocStatus() DocStatus {
	return DocStatus{path: "", isAlreadyExisting: true}
}

func (docStatus *DocStatus) IsAlreadyExisting() bool {
	return docStatus.isAlreadyExisting
}

func (docStatus *DocStatus) isEmpty() bool {
	return len(docStatus.path) == 0
}

func GetPaths(docStatuses []DocStatus) []string {
	docPaths := []string{}

	for _, ds := range docStatuses {
		docPaths = append(docPaths, ds.path)
	}
	return docPaths
}
