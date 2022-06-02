package new_docs

import (
	"fmt"
	"io"
	"log"
	"os"
)

// GenerateNewDocs writes to each doc in provided docs.
func GenerateNewDocs(newDocsInput []NewDocInput, newDocsDirectory string) ([]string, error) {
	if err := os.Mkdir(newDocsDirectory, 0777); err != nil {
		return []string{}, fmt.Errorf("error creating release docs directory: %v", err)
	}
	log.Printf("Created new docs directory %v\n\n", newDocsDirectory)

	var newFiles []string
	for _, doc := range newDocsInput {
		fullFilePath := fmt.Sprint(newDocsDirectory + "/" + doc.FileName)
		err := writeToNewDoc(doc, fullFilePath)

		if err != nil {
			if errRemoveAll := os.RemoveAll(newDocsDirectory); errRemoveAll != nil {
				log.Printf("error deleting directory and all content: %v", errRemoveAll)
			}
			return []string{}, fmt.Errorf("error with writing to docs: %v", err)
		}
		newFiles = append(newFiles, fullFilePath)
		log.Printf("Successfully wrote to %v\n", doc.FileName)
	}
	return newFiles, nil
}

func writeToNewDoc(doc NewDocInput, fullFilePath string) error {
	docFile, err := os.Create(fullFilePath)
	docsWriter := io.Writer(docFile)
	doc.TemplateWriter.WriteTo(docsWriter)

	if doc.AppendToEnd != nil {
		additionalText, appendErr := doc.AppendToEnd()
		if appendErr != nil {
			closeFile(docFile)
			return fmt.Errorf("error while trying to get additional text append to file: %v", appendErr)
		}
		if _, err = docFile.WriteString(additionalText + "\n"); err != nil {
			closeFile(docFile)
			return fmt.Errorf("error while appending additional text to file: %v", err)
		}
	}
	closeFile(docFile)
	return nil
}

func closeFile(f *os.File) {
	if err := f.Close(); err != nil {
		log.Printf("Encountered error when attempting to close file: %v\n", err)
	}
}
