#!/bin/bash

# Output directory
output_dir="generated-combos"
mkdir -p "$output_dir"

# Define ranges for each tier
upper_range=$(seq 0 9)
middle_range=$(seq 0 9)
lower_range=$(seq 0 9)

# Global backtest parameters
year=2022
month=1
initialUsdc=1000
strategy="MacroUptrend"

count=0

for u in $upper_range; do
  for m in $middle_range; do
    for l in $lower_range; do

      # Skip 0,0,0
      if [[ "$u" -eq 0 && "$m" -eq 0 && "$l" -eq 0 ]]; then
        continue
      fi

      filename="$output_dir/combo-${u}-${m}-${l}.yaml"
      cat <<EOF > "$filename"
backtestParameters:
  year: $year
  month: $month
  initialUsdc: $initialUsdc
  strategy: $strategy
combo:
  upper: $u
  middle: $m
  lower: $l
EOF
      ((count++))
    done
  done
done

echo "✅ Generated $count combo YAML files in $output_dir/"
