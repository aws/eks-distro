package projects

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
)

const (
	gitTagFilename = "GIT_TAG"
	golangFilename = "GOLANG_VERSION"
)

type Version struct {
	gitTag string
	golang string
}

func (v *Version) GetGitTag() string {
	return v.gitTag
}

func (v *Version) GetGolang() string {
	return v.golang
}

func readGitTagVersionFile(parentPath string) ([]byte, error) {
	return readVersionFile(filepath.Join(parentPath, gitTagFilename))
}

func readGolangVersionFile(parentPath string) ([]byte, error) {
	return readVersionFile(filepath.Join(parentPath, golangFilename))
}

func readVersionFile(versionFilepath string) ([]byte, error) {
	fileOutput, err := os.ReadFile(versionFilepath)
	if err != nil {
		return []byte{}, fmt.Errorf("reading version at %s path:%w", versionFilepath, err)
	}
	return bytes.TrimSpace(fileOutput), nil
}
