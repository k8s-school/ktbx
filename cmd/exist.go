/*
Copyright © 2023 Fabrice Jammmes fabrice.jammes@k8s-school.fr
*/
package cmd

import (
	"github.com/spf13/cobra"
)

// deskCmd represents the desk command
var existCmd = &cobra.Command{
	Use:     "exist",
	Aliases: []string{"e"},
	Short:   "Wait for a kubernetes resource to exist",
	Long:    `Lauch a interactive shell with k8s client tools installed, inside a docker container, it mounts host directories $HOME/.kube in $HOME/.kube and homefs/ in $HOME`,
	Run: func(cmd *cobra.Command, args []string) {

		// TODO

	},
}

func init() {
	rootCmd.AddCommand(existCmd)

}

// package main

// import (
//     "context"
//     "flag"
//     "fmt"
//     "os"
//     "time"

//     corev1 "k8s.io/api/core/v1"
//     metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
//     "k8s.io/client-go/kubernetes"
//     "k8s.io/client-go/tools/clientcmd"
// )

// func waitForExist(clientset *kubernetes.Clientset, ns string, resourceType string, maxWaitSecs int, resource string) error {
//     intervalSecs := 2 * time.Second
//     startTime := time.Now()

//     for {
//         fmt.Printf("Waiting for %s %s\n", resourceType, resource)

//         if time.Since(startTime).Seconds() > float64(maxWaitSecs) {
//             return fmt.Errorf("waited for %s in namespace \"%s\" to exist for %d seconds without luck", resourceType, ns, maxWaitSecs)
//         }

//         _, err := clientset.CoreV1().Namespaces().Get(context.Background(), resource, metav1.GetOptions{})

//         if err == nil {
//             break
//         } else {
//             time.Sleep(intervalSecs)
//         }
//     }

//     return nil
// }

// func main() {
//     kubeconfig := flag.String("kubeconfig", "~/.kube/config", "path to the kubeconfig file")
//     ns := flag.String("namespace", "", "the namespace")
//     resourceType := flag.String("type", "", "the resource type")
//     maxWaitSecs := flag.Int("timeout", 120, "the maximum wait time in seconds")
//     flag.Parse()
//     args := flag.Args()

//     if len(args) < 1 {
//         fmt.Println("Please provide a resource to check")
//         os.Exit(1)
//     }

//     resource := args[0]

//     config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
//     if err != nil {
//         panic(err)
//     }

//     clientset, err := kubernetes.NewForConfig(config)
//     if err != nil {
//         panic(err)
//     }

//     err = waitForExist(clientset, *ns, *resourceType, *maxWaitSecs, resource)
//     if err != nil {
//         fmt.Println(err)
//         os.Exit(1)
//     }
// }
