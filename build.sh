#!/bin/bash -e

if [ -z "$1" ]
then
    echo "No argument supplied, please either supply 'release' for a release build or 'ci' for ci build."
    exit 1
fi

source /build_environment.sh

# Grab the last segment from the package name
name=${pkgName##*/}

echo "Running Tests $pkgName..."
(
  go test -v $(glide novendor) || exit 1
)

if [ "$1" == "release" ]
then
  echo "Release Building $pkgName..."
  CGO_ENABLED=${CGO_ENABLED:-0} \
  goreleaser
else
  # Compile statically linked version of package
  if [ -z "$2" ]
  then
    echo "No argument supplied for the 'version', please the version string as second argument."
    exit 1
  fi

  output="./dist/${name}"
  versionFlag="-X main.version=$2"

  echo "CI Building $pkgName..."
  (
    CGO_ENABLED=${CGO_ENABLED:-0} \
    go build \
    -a \
    -o ${output} \
    --ldflags="${LDFLAGS:--s} ${versionFlag}" \
    -v \
    $pkgName
  )
fi
