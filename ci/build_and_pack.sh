#!/bin/bash

set -x

ASSETS=${ASSETS:-/tmp/assets}
GRAFANA_VERSION=${GRAFANA_VERSION:-5.0.3}

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base <arch>
Build and package grafana (armv6, armv7 or arm64) reusing offical assets
Available arch:
  $base armv6
  $base armv7
  $base arm64
EOUSAGE
}

if [[ -z `docker images fg2it/fgbw -q` ]]; then
  ci/createImage.py ${GRAFANA_VERSION}
fi
if [[ -z `docker volume ls -q | grep assets-fgbw` ]]; then
  docker volume create assets-fgbw
fi

for ARM in "$@"
do
  case "$ARM" in
    armv6)
      ;;
    armv7)
      ;;
    arm64)
      ;;
    *)
      echo >&2 'error: unknown arch:' "$ARM"
      usage >&2
      exit 1
      ;;
  esac
  docker run --rm -v assets-fgbw:/tmp/assets/ fg2it/fgbw /build.sh ${ARM}
  ci/package.sh ${ARM}
done
