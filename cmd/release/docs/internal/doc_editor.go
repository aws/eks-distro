package internal
//
//import (
//	. "../../internal"
//	"bytes"
//	"fmt"
//	"io/ioutil"
//	"log"
//	"os"
//	"regexp"
//)
//
///*
//### Kubernetes 1-18
//
//| Release | Manifest |
//| --- | --- |
//| 4 | [kubernetes-1-18-eks-4](https://distro.eks.amazonaws.com/kubernetes-1-18/kubernetes-1-18-eks-4.yaml) |
//
//### Kubernetes 1-19
//
//| Release | Manifest |
//| --- | --- |
//| 4 | [kubernetes-1-19-eks-4](https://distro.eks.amazonaws.com/kubernetes-1-19/kubernetes-1-19-eks-4.yaml) |
//
//### Kubernetes 1-20
//
//| Release | Manifest |
//| --- | --- |
//| 1 | [kubernetes-1-20-eks-1](https://distro.eks.amazonaws.com/kubernetes-1-20/kubernetes-1-20-eks-1.yaml) |
//*/
//
//
//func UpdateREADME(release *Release) error {
//
//	readmePath := GetREADMEPath()
//	data, err := ioutil.ReadFile(readmePath)
//	if err != nil {
//		return fmt.Errorf("failed to read file because error: %v", err)
//	}
//
//	linebreak := []byte("\n")
//	splitData := bytes.Split(data, linebreak)
//
//	prefix := []byte("|")
//	hasFoundLine := false
//
//	re := regexp.MustCompile(fmt.Sprintf(`[%s]`, release.K8sBranchEKSPreviousNumber))
//
//	for i, line := range splitData {
//		if !bytes.HasPrefix(line, prefix) {
//			continue
//		}
//
//		if  !re.Match(line){
//			continue
//		}
//
//		hasFoundLine = true
//
//		newLine := fmt.Sprintf("| %s |")
//
//		| 4 | [kubernetes-1-18-eks-4](https://distro.eks.amazonaws.com/kubernetes-1-18/kubernetes-1-18-eks-4.yaml) |
//
//		splitData[i] = bytes.Replace(line, prevVersionTagToEndOfLine, versionTagToEndOfLine, 1)
//		break
//	}
//
//	if !hasFoundLine {
//		return fmt.Errorf("failed to find line starting with %q that is needed to update version tag", prefix)
//	}
//	return os.WriteFile(readmePath, bytes.Join(splitData, linebreak), 0644)
//}