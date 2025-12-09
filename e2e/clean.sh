#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

ktbx delete -n home-ci