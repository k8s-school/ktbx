#!/usr/bin/env bash

# Publish a qserv-ingest release
# TODO use https://github.com/toshimaru/nyan/blob/main/.github/workflows/release.yml

# @author  Fabrice Jammes, IN2P3

set -euxo pipefail

releasetag=""

DIR=$(cd "$(dirname "$0")"; pwd -P)

usage() {
  cat << EOD

Usage: `basename $0` [options] RELEASE_TAG

  Available options:
    -h          this message

Create a k8s-toolbox release tagged "RELEASE_TAG"
RELEASE_TAG must have the semver format. 
EOD
}

# get the options
while getopts ht: c ; do
    case $c in
	    h) usage ; exit 0 ;;
	    \?) usage ; exit 2 ;;
    esac
done
shift `expr $OPTIND - 1`

if [ $# -ne 1 ] ; then
    usage
    exit 2
fi

releasetag=$1

# TODO update VERSION in README.md
sed -i "s/^K8S_TOOLBOX_VERSION=.*$/K8S_TOOLBOX_VERSION='$releasetag'/" $DIR/install.sh
git add .
git commit -m "Publish release $releasetag"
git tag -a "$releasetag" -m "Version $releasetag"
git push --follow-tags
rm -rf $DIR/dist
goreleaser release
