package pull_request

import (
	"errors"
	"fmt"
	"strings"
	"time"
)

const filePathDelimiter = " "

type PullRequest struct {
	branch        string
	commitMessage string
	filesPaths    string
}

type PullRequestInput interface {
	Branch() string
	Number() string
	Environment() string
	Version() string
}

func NewPullRequestForDocs(input PullRequestInput, filesPaths []string) (PullRequest, error) {
	pullRequest, err := getUniversalPullRequest(input.Version()+"-docs", filesPaths)
	if err != nil {
		return PullRequest{}, err
	}
	pullRequest.commitMessage = fmt.Sprintf("Created and updated docs for %s", input.Version())
	return pullRequest, nil
}

func NewPullRequestForNumber(input PullRequestInput, filesPaths []string) (PullRequest, error) {
	pullRequest, err := getUniversalPullRequest(input.Version()+"-"+input.Environment(), filesPaths)
	if err != nil {
		return PullRequest{}, err
	}
	pullRequest.commitMessage = fmt.Sprintf("Bumped %s RELEASE for %s", input.Environment(), input.Version())
	return pullRequest, nil
}

func getUniversalPullRequest(branchBase string, filesPaths []string) (PullRequest, error) {
	convertedFilePaths, err := convertFilePaths(filesPaths)
	if err != nil {
		return PullRequest{}, fmt.Errorf("failed to make new pull request due to error with file paths: %v", err)
	}
	return PullRequest{
		branch:     formatBranch(branchBase),
		filesPaths: convertedFilePaths,
	}, nil
}

func convertFilePaths(filesPaths []string) (string, error) {
	if len(filesPaths) == 0 {
		return "", errors.New("no file paths provided")
	}

	filePathsAsString := ""
	for _, filepath := range filesPaths {
		trimmedFilePath := strings.TrimSpace(filepath)
		if len(trimmedFilePath) == 0 {
			continue
		}
		filePathsAsString = filePathsAsString + trimmedFilePath + filePathDelimiter
	}

	if len(filePathsAsString) == 0 {
		return "", errors.New("no non-empty file paths provided")
	}
	return strings.TrimSuffix(filePathsAsString, filePathDelimiter), nil
}

func formatBranch(branchNameBase string) string {
	return fmt.Sprintf("\"%s-%d\"", branchNameBase, time.Now().Unix())
}
