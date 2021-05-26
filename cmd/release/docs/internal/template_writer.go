package internal

import (
	. "../../internal"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"log"
	"os"
	"text/template"
)

type Doc struct {
	Filename     string
	TemplateName string
	IsIncluded   bool
	AppendToEnd  func(release *Release) (string, error)
}

var closeFile = func(f *os.File) {
	if err := f.Close(); err != nil {
		log.Printf("Encountered error when attempting to close file: %v\n", err)
	}
}

// WriteToDocs writes to each doc in provided docs with the information supplied by release, with overrideIfExisting
// conditionally replacing existing file content with the generated content.
func WriteToDocs(docs []Doc, release *Release, overrideIfExisting bool) ([]DocStatus, error) {
	var docStatuses []DocStatus

	err := os.Mkdir(release.DocsDirectoryPath, 0777)
	if err != nil {
		if errors.Is(err, fs.ErrExist) {
			log.Printf("Directory %v already exists\n\n", release.DocsDirectoryPath)
		} else {
			return docStatuses, fmt.Errorf("error creating release docs directory: %v", err)
		}
	} else {
		log.Printf("Created new docs directory %v\n\n", release.DocsDirectoryPath)
	}

	for _, doc := range docs {
		if doc.IsIncluded {
			ds, err := writeToDoc(&doc, release, overrideIfExisting)
			if err != nil {
				return docStatuses, fmt.Errorf("error with writing to docs and failed to finish: %v", err)
			}
			docStatuses = append(docStatuses, ds)
		}
	}
	return docStatuses, nil
}

func writeToDoc(doc *Doc, release *Release, overrideIfExisting bool) (DocStatus, error) {
	filePath := fmt.Sprintf(release.DocsDirectoryPath + "/" + doc.Filename)

	ds := DocStatus{path: filePath}

	_, err := os.Stat(filePath)
	if os.IsNotExist(err) {
		ds.isAlreadyExisting = false
	} else if err == nil {
		ds.isAlreadyExisting = true
		if overrideIfExisting {
			fmt.Printf("file %v already exists but ignoring error because force option\n", filePath)
		} else {
			return DocStatus{}, fmt.Errorf("file %v already exists and override option not enabled", filePath)
		}
	} else {
		return DocStatus{}, fmt.Errorf("encountered error checking file: %v", err)
	}

	docFile, err := os.Create(filePath)
	if err != nil {
		return ds, fmt.Errorf("error while creating file: %v", err)
	}
	defer closeFile(docFile)

	docsWriter := io.Writer(docFile)

	t := template.Must(template.New("docTemplate").Parse(doc.TemplateName))
	err = t.Execute(docsWriter, release)
	if err != nil {
		return ds, fmt.Errorf("error while writing to file: %v", err)
	}

	if doc.AppendToEnd != nil {
		fmt.Println("Appending additional text to file " + filePath)

		additionalText, err := doc.AppendToEnd(release)
		if err != nil {
			return ds, fmt.Errorf("error while trying to get additional text append to file: %v", err)
		}

		if _, err = docFile.WriteString("\n" + additionalText + "\n"); err != nil {
			return ds, fmt.Errorf("error while appending additional text to file: %v", err)
		}
	}

	log.Printf("Successfully wrote to %v\n", filePath)
	return ds, nil
}

// DeleteDocsDirectoryIfEmpty deletes docs directory for provided release if the directory is empty.
func DeleteDocsDirectoryIfEmpty(release *Release) {
	dir, err := os.Open(release.DocsDirectoryPath)
	if err != nil {
		fmt.Printf("failed to open docs directory to delete it: %v\n", err)
		return
	}

	defer closeFile(dir)

	_, err = dir.Readdir(1)
	if err == io.EOF {
		deleteErr := os.Remove(release.DocsDirectoryPath)
		if deleteErr != nil {
			log.Printf("Error while attempting to delete empty docs directory: %v\n", err)
		} else {
			log.Println("Deleted docs directory because it is empty")
		}
	} else if err != nil {
		log.Printf("Error while attempting to read docs directory to possibly delete it: %v\n", err)
	} else {
		log.Println("Docs directory is not empty, so will not delete it as part of clean up")
	}
}
