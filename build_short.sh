#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"
TOPIC=${1:-childhood-cancer}

if [ "$TOPIC" = "childhood-cancer" ]; then
  NARRATION=video_narration.txt
else
  NARRATION="${TOPIC}-video_narration.txt"
fi

cleanup() {
  rm -f "${TOPIC}-silent.mov" "${TOPIC}-video-only.m4v" "${TOPIC}-narration.aiff" "${TOPIC}-narration.m4a"
}
trap cleanup EXIT INT TERM

say -v Samantha -r 170 -f "$NARRATION" -o "${TOPIC}-narration.aiff"
swift render_short.swift "$ROOT" "$TOPIC"
avconvert --source "${TOPIC}-silent.mov" --preset PresetHighestQuality --output "${TOPIC}-video-only.m4v" --replace
avconvert --source "${TOPIC}-narration.aiff" --preset PresetAppleM4A --output "${TOPIC}-narration.m4a" --replace
swift mux_audio.swift "$ROOT" "$TOPIC"

printf 'Ready: %s/%s-short.mp4\n' "$ROOT" "$TOPIC"
