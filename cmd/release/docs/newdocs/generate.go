package newdocs

import (
	"fmt"
	"io"
	"log"
	"os"

	"github.com/aws/eks-distro/cmd/release/utils/values"
)

// GenerateNewDocs writes to each doc in provided docs.
func GenerateNewDocs(newDocsInput []NewDocInput, docsDir values.NewDirectory) error {
	for _, doc := range newDocsInput {
		fullFilePath := fmt.Sprint(docsDir.String() + "/" + doc.FileName)
		err := writeToNewDoc(doc, fullFilePath)
		if err != nil {
			return fmt.Errorf("writing to new docs: %w", err)
		}
		log.Printf("Successfully wrote to %v\n", doc.FileName)
	}
	return nil
}

func writeToNewDoc(doc NewDocInput, fullFilePath string) error {
	docFile, err := os.Create(fullFilePath)
	if err != nil {
		return fmt.Errorf("creating file %s: %w", fullFilePath, err)
	}

	docsWriter := io.Writer(docFile)
	_, err = doc.TemplateWriter.WriteTo(docsWriter)
	if err != nil {
		return fmt.Errorf("writing to file %s: %w", fullFilePath, err)
	}

	if doc.AppendToEnd != nil {
		additionalText, appendErr := doc.AppendToEnd()
		if appendErr != nil {
			closeFile(docFile)
			return fmt.Errorf("getting additional text append to file: %w", appendErr)
		}
		if _, err = docFile.WriteString(additionalText + "\n"); err != nil {
			closeFile(docFile)
			return fmt.Errorf("appending additional text to file: %w", err)
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
