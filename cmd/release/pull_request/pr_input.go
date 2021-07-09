package pull_request

import (
	"errors"
	"fmt"
	"strings"
	"time"
)

const filePathDelimiter = " "

type DocsPullRequestInput interface {
	Branch() string
	Version() string
}

type NumberPullRequestInput interface {
	DocsPullRequestInput
	Environment() string
}

func NewPullRequestForDocs(input DocsPullRequestInput, filesPaths []string) (PullRequest, error) {
	pullRequest, err := getCommonPullRequest(input.Version()+"-docs", filesPaths)
	if err != nil {
		return PullRequest{}, err
	}
	pullRequest.commitMessage = fmt.Sprintf("Created and updated docs for %s", input.Version())
	return pullRequest, nil
}

func NewPullRequestForNumber(input NumberPullRequestInput, filesPaths []string) (PullRequest, error) {
	pullRequest, err := getCommonPullRequest(input.Version()+"-"+input.Environment(), filesPaths)
	if err != nil {
		return PullRequest{}, err
	}
	pullRequest.commitMessage = fmt.Sprintf("Bumped %s RELEASE for %s", input.Environment(), input.Version())
	return pullRequest, nil
}

func getCommonPullRequest(branchBase string, filesPaths []string) (PullRequest, error) {
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
			return "", errors.New("encountered an empty file path")
		}
		filePathsAsString = filePathsAsString + trimmedFilePath + filePathDelimiter
	}

	return strings.TrimSuffix(filePathsAsString, filePathDelimiter), nil
}

func formatBranch(branchNameBase string) string {
	return fmt.Sprintf("%s-%d", branchNameBase, time.Now().Unix())
}
