/*
Copyright © 2023 Fabrice Jammes fabrice.jammes@in2p3.fr

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
package cmd

import (
	"fmt"

	"runtime/debug"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(versionCmd)

	versionCmd.Flags().BoolP("quiet", "q", false, "only print version number")

}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version number of k8s-toolbox",
	Run: func(cmd *cobra.Command, args []string) {
		version, sum := Version()
		quiet, _ := cmd.Flags().GetBool("quiet")

		if quiet {
			fmt.Print(version)
			return
		} else {
			fmt.Printf("k8s-toolbox, version: %v, checksum: %v", version, sum)
		}
	},
}

// Version returns the version of k8s-toolbox and its checksum.
func Version() (version, sum string) {
	b, ok := debug.ReadBuildInfo()
	if !ok {
		return "", ""
	}
	if b == nil {
		version = "nil"
	} else {
		version = b.Main.Version
		sum = b.Main.Sum
	}
	return version, sum
}
