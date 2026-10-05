#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"

cleanup() {
  rm -f childhood-cancer-silent.mov childhood-cancer-video-only.m4v childhood-cancer-narration.aiff childhood-cancer-narration.m4a
}
trap cleanup EXIT INT TERM

say -v Samantha -r 170 -f video_narration.txt -o childhood-cancer-narration.aiff
swift render_short.swift "$ROOT"
avconvert --source childhood-cancer-silent.mov --preset PresetHighestQuality --output childhood-cancer-video-only.m4v --replace
avconvert --source childhood-cancer-narration.aiff --preset PresetAppleM4A --output childhood-cancer-narration.m4a --replace
swift mux_audio.swift "$ROOT"

printf 'Ready: %s/childhood-cancer-short.mp4\n' "$ROOT"
