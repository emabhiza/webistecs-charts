#!/bin/bash

output_dir="$(dirname "$0")/generated-combos"
mkdir -p "$output_dir"

upper_range=$(seq -0.5 -0.5 -5.0 | awk '{printf "%.2f\n", $1}')
middle_range=$(seq -5.0 -0.5 -10.0 | awk '{printf "%.2f\n", $1}')
lower_range=$(seq -10.0 -0.5 -15.0 | awk '{printf "%.2f\n", $1}')

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
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: backtest-${safe_u}-${safe_m}-${safe_l}-
spec:
  workflowTemplateRef:
    name: backtester-template
    namespace: default
  arguments:
    parameters:
    - name: year
      value: "$year"
    - name: month
      value: "$month"
    - name: initialUsdc
      value: "$initialUsdc"
    - name: strategy
      value: "$strategy"
    - name: Combo_Upper_Start
      value: "$u"
    - name: Combo_Upper_EndValue
      value: "$(echo "$u - 0.5" | bc)"
    - name: Combo_Upper_Target
      value: "$u_target"
    - name: Combo_Upper_Weight
      value: "5"
    - name: Combo_Middle_Start
      value: "$m"
    - name: Combo_Middle_EndValue
      value: "$(echo "$m - 0.5" | bc)"
    - name: Combo_Middle_Target
      value: "$m_target"
    - name: Combo_Middle_Weight
      value: "10"
    - name: Combo_Lower_Start
      value: "$l"
    - name: Combo_Lower_EndValue
      value: "$(echo "$l - 0.5" | bc)"
    - name: Combo_Lower_Target
      value: "$l_target"
    - name: Combo_Lower_Weight
      value: "15"
EOF
      ((count++))
    done
  done
done

echo "✅ Generated $count combo YAML files in $output_dir/"
