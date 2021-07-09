package pull_request

import (
	. "../internal"
	"io"
	"log"
	"os"
	"os/exec"
)

var (
	outputStream io.Writer = os.Stdout
	errStream    io.Writer = os.Stderr
)

func (pr PullRequest) Open() {
	prScriptPath := GetPRScriptPath()
	cmd := exec.Command("/bin/bash", prScriptPath, pr.branch, pr.commitMessage, pr.filesPaths)

	cmd.Stdout = outputStream
	cmd.Stderr = errStream
	err := cmd.Run()
	if err != nil {
		//println(string(out))
		log.Fatal(err)
	}

	//stderr := &bytes.Buffer{}
	//stdout := &bytes.Buffer{}
	//cmd.Stderr = stderr
	//cmd.Stdout = stdout
	//if err := cmd.Run(); err != nil {
	//	fmt.Println("Error: ", err, "|", stderr.String())
	//} else {
	//	fmt.Println(stdout.String())
	//}
	//os.Exit(0)

	//resetPath := "checkout HEAD^ -- " + release.EnvironmentReleasePath
	//exec.Command("git", resetPath)
	//log.Fatalf("Error running make: %v", err)

}
