#!/bin/bash

# get the root of the directory
REPO_ROOT=$(git rev-parse --show-toplevel)

# ensure that the command below is run from the root of the repository
cd "$REPO_ROOT"

export NXF_VER=21.10.6

bin/nextflow \
  run . \
  -main-script workflows/integration/multiomics/main.nf \
  -entry test_wf \
  -resume \
  -profile docker \
  -c workflows/utils/labels_ci.config \
  --publish_dir "foo/"