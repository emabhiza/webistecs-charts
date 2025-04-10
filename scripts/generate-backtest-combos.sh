#!/bin/bash

output_dir="$(dirname "$0")/generated-combos"
mkdir -p "$output_dir"

upper_range=$(seq -0.5 -0.5 -5.0 | awk '{printf "%.1f\n", $1}')
middle_range=$(seq -5.0 -0.5 -10.0 | awk '{printf "%.1f\n", $1}')
lower_range=$(seq -10.0 -0.5 -15.0 | awk '{printf "%.1f\n", $1}')

year=2022
month=1
initialUsdc=1000
strategy="MacroUptrend"

count=0

for u in $upper_range; do
  for m in $middle_range; do
    for l in $lower_range; do

      u_target=$(echo "scale=2; ($u + ($u - 0.5))/2" | bc)
      m_target=$(echo "scale=2; ($m + ($m - 0.5))/2" | bc)
      l_target=$(echo "scale=2; ($l + ($l - 0.5))/2" | bc)

      # Sanitize filename - replace "." with "-"
      safe_u=${u//./-}
      safe_m=${m//./-}
      safe_l=${l//./-}

      filename="$output_dir/combo-${safe_u}-${safe_m}-${safe_l}.yaml"

      cat <<EOF > "$filename"
backtestParameters:
  year: $year
  month: $month
  initialUsdc: $initialUsdc
  strategy: $strategy
combo:
  upper:
    start: $u
    endValue: $(echo "$u - 0.5" | bc)
    target: $u_target
    weight: 5
    tier: Upper
  middle:
    start: $m
    endValue: $(echo "$m - 0.5" | bc)
    target: $m_target
    weight: 10
    tier: Middle
  lower:
    start: $l
    endValue: $(echo "$l - 0.5" | bc)
    target: $l_target
    weight: 15
    tier: Lower
EOF

      ((count++))
    done
  done
done

echo "✅ Generated $count combo YAML files in $output_dir/"
