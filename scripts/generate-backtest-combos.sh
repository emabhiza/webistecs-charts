#!/bin/bash

# Output directory
output_dir="generated-combos"
mkdir -p "$output_dir"

# Define ranges for each tier based on the C# code
# Upper: -0.5 to -5.0 in steps of 0.5
upper_range=$(seq -0.5 -0.5 -5.0 | awk '{printf "%.1f\n", $1}')
# Middle: -5.0 to -10.0 in steps of 0.5
middle_range=$(seq -5.0 -0.5 -10.0 | awk '{printf "%.1f\n", $1}')
# Lower: -10.0 to -15.0 in steps of 0.5
lower_range=$(seq -10.0 -0.5 -15.0 | awk '{printf "%.1f\n", $1}')

# Global backtest parameters
year=2022
month=1
initialUsdc=1000
strategy="MacroUptrend"

count=0

for u in $upper_range; do
  for m in $middle_range; do
    for l in $lower_range; do
      # Calculate target for each arm (midpoint between start and end)
      u_target=$(echo "scale=2; ($u + ($u - 0.5))/2" | bc)
      m_target=$(echo "scale=2; ($m + ($m - 0.5))/2" | bc)
      l_target=$(echo "scale=2; ($l + ($l - 0.5))/2" | bc)

      filename="$output_dir/combo-${u}-${m}-${l}.yaml"
      cat <<EOF > "$filename"
backtestParameters:
  year: $year
  month: $month
  initialUsdc: $initialUsdc
  strategy: $strategy
combo:
  upper:
    start: $u
    end: $(echo "$u - 0.5" | bc)
    target: $u_target
    weight: 5
    tier: Upper
  middle:
    start: $m
    end: $(echo "$m - 0.5" | bc)
    target: $m_target
    weight: 10
    tier: Middle
  lower:
    start: $l
    end: $(echo "$l - 0.5" | bc)
    target: $l_target
    weight: 15
    tier: Lower
EOF
      ((count++))
    done
  done
done

echo "✅ Generated $count combo YAML files in $output_dir/"