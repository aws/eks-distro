package main

import (
	internalpkg "../internal"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

var (
//gitRoot string = getRootDirectorySafe()
)

type Release struct {
	releaseBranch string
	number        string
	prevNumber    string
	//isCompleteNeeded   bool
	releaseEnvironment string
	ReleaseVersionName string
}

func (release Release) GetReleaseNumber() string {
	return release.number
}

func (release Release) GetReleaseBranch() string {
	return release.releaseBranch
}

// TODO split structs into two
func (release Release) GetReleaseEnvironment() string {
	return release.releaseEnvironment
}

//func getRootDirectorySafe() string {
//	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
//	if err != nil {
//		return ""
//	}
//	return strings.Join(strings.Fields(string(gitRootOutput)), "")
//}

func GetRootDirectory() (string, error) {
	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		return "", err
	}

	return strings.Join(strings.Fields(string(gitRootOutput)), ""), nil
}

func getFileContentsAsString(filepath string) (string, error) {
	fileOutput, err := ioutil.ReadFile(filepath)
	return string(fileOutput), err
}

func getFileContentsTrimmedAsString(filepath string) (string, error) {
	fileOutput, err := getFileContentsAsString(filepath)
	return strings.TrimSpace(fileOutput), err
}

// TODO: change to error handle
func check(e error) {
	if e != nil {
		panic(e)
	}
}



func main() {
	releaseBranch := flag.String("pkg-branch", "", "Release releaseBranch")
	releaseEnvironment := flag.String("pkg-environment", "development", "Must be 'development' or 'production'")
	number := flag.String("number", "", "Release to test")
	//prevNumber := flag.String("prevNumber", "", "Release to test")
	//isCompleteNeeded := flag.Bool("is-complete-needed", false, "True if is automates")

	flag.Parse()

	release := &Release{
		releaseBranch:      *releaseBranch,
		releaseEnvironment: *releaseEnvironment,
		number:             *number,
		//prevNumber:       *prevNumber,
		//isCompleteNeeded: *isCompleteNeeded,
	}


	//if release.gitRoot == "" {
	//	gitRootOutput, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	//	if err != nil {
	//		log.Fatalf("Error running finding git root: %v", err)
	//	}
	//	release.gitRoot = strings.Fields(string(gitRootOutput))[0]

	releasePath, err := internalpkg.GetReleasePath(release)
	check(err)
	release.prevNumber, err = getFileContentsTrimmedAsString(releasePath)
	check(err)

	prevNumberAsInt, err := strconv.Atoi(release.prevNumber)
	check(err)
	if len(release.number) == 0 {
		release.number = strconv.Itoa(prevNumberAsInt + 1)
	} else {
		numberAsInt, err := strconv.Atoi(release.number)
		check(err)

		if numberAsInt <= prevNumberAsInt {
			panic("cannot have this") // TODO better message
		} else if numberAsInt != prevNumberAsInt+1 {
			fmt.Println("WARNING! Increase in numbers is greater than 1") // TODO better message
		}
	}

	err = os.WriteFile(releasePath, []byte(release.number+"\n"), 0644)
	check(err)


	rootdir, _ := GetRootDirectory()

	pathway := rootdir + "/cmd/release/scripts/create_release_pr.sh"
	fmt.Println(pathway)

	cmd, err := exec.Command("/bin/bash",
		pathway,
		releasePath).Output()
	if err != nil {
		fmt.Printf("error %s", err)
	}
	output := string(cmd)
	fmt.Println(output)

}
