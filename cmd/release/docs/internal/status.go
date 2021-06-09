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

func (DocStatus *DocStatus) UndoChanges() error {
	docPath := DocStatus.path

	_, err := os.Stat(docPath)
	if err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			log.Printf("Did not delete file because it does not exist: %s", docPath)
			return nil
		}
		return fmt.Errorf("failed to delete file because encountered error: %v", err)
	}

	if DocStatus.isAlreadyExisting {
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
