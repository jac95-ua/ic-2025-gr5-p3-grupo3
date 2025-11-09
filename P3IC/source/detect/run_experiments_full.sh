#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Determine number of processors
NPROC=$(nproc)

# Base thread set; include 1,2,4,8 and the detected NPROC (if not already present)
THREADS_RAW=(1 2 4 8 $NPROC)

# Deduplicate and keep sorted
THREADS=()
for t in "${THREADS_RAW[@]}"; do
  if [[ $t -ge 1 ]]; then
    THREADS+=("$t")
  fi
done

# Remove duplicates and sort unique
IFS=$'\n' THREADS=($(printf "%s\n" "${THREADS[@]}" | sort -n | awk '!seen[$0]++'))
unset IFS

REPS=5
OUTCSV=run_results_full.csv
echo "threads,rep,time_ms" > "$OUTCSV"

IMG="build/face_swap_enhanced.png"

echo "Running full experiment: threads=${THREADS[*]} reps=$REPS img=$IMG"

for t in "${THREADS[@]}"; do
  export OMP_NUM_THREADS=$t
  for ((r=1;r<=REPS;r++)); do
    echo "Running: threads=$t rep=$r"
    out=$(./build/detect "$IMG" 2>&1 | tee /dev/stderr | sed -n 's/.*Total elapsed time: \([0-9]*\)ms.*/\1/p' | tail -n1)
    if [[ -z "$out" ]]; then
      echo "ERROR: could not parse time for threads=$t rep=$r" >&2
      exit 1
    fi
    echo "$t,$r,$out" >> "$OUTCSV"
  done
done

echo "Full results written to $OUTCSV"
