#!/bin/bash

output_dir="$(dirname "$0")/generated-combos"
mkdir -p "$output_dir"

upper_range=$(seq -0.5 -0.5 -5.0)
middle_range=$(seq -5.0 -0.5 -10.0)
lower_range=$(seq -10.0 -0.5 -15.0)

year=2022
month=1
initialUsdc=1000
strategy="MacroUptrend"

count=0

# A helper function to format floats to two decimals with a leading zero if needed.
# Example: -0.5 => -0.50, -.75 => -0.75, .25 => 0.25
format_float() {
  # We rely on 'bc' and 'awk' to produce a float with two decimals
  echo "scale=2; $1" | bc | awk '{printf "%.2f", $1}'
}

for u in $upper_range; do
  for m in $middle_range; do
    for l in $lower_range; do

      # Format the 'start' values so they always have two decimals (e.g., -0.50)
      u_formatted=$(format_float "$u")
      m_formatted=$(format_float "$m")
      l_formatted=$(format_float "$l")

      # Calculate the endValue and target for each and format them
      u_endValue=$(format_float "$(echo "$u - 0.5" | bc)")
      m_endValue=$(format_float "$(echo "$m - 0.5" | bc)")
      l_endValue=$(format_float "$(echo "$l - 0.5" | bc)")

      u_target=$(format_float "$(echo "($u + ($u - 0.5))/2" | bc)")
      m_target=$(format_float "$(echo "($m + ($m - 0.5))/2" | bc)")
      l_target=$(format_float "$(echo "($l + ($l - 0.5))/2" | bc)")

      # Sanitize filename: replace "." with "-"
      safe_u=${u_formatted//./-}
      safe_m=${m_formatted//./-}
      safe_l=${l_formatted//./-}

      filename="$output_dir/combo-${safe_u}-${safe_m}-${safe_l}.yaml"

      cat <<EOF > "$filename"
backtestParameters:
  year: $year
  month: $month
  initialUsdc: $initialUsdc
  strategy: $strategy
combo:
  upper:
    start: $u_formatted
    endValue: $u_endValue
    target: $u_target
    weight: 5
    tier: Upper
  middle:
    start: $m_formatted
    endValue: $m_endValue
    target: $m_target
    weight: 10
    tier: Middle
  lower:
    start: $l_formatted
    endValue: $l_endValue
    target: $l_target
    weight: 15
    tier: Lower
EOF

      ((count++))
    done
  done
done

echo "✅ Generated $count combo YAML files in $output_dir/"
