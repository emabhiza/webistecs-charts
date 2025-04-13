#!/bin/bash

# Config
output_dir="./generated-jobs"
mkdir -p "$output_dir"

# Resources
memory_request="8Gi"
memory_limit="10Gi"
cpu_request="3000m"  # Request 3 cores
cpu_limit="6000m"    # Allow up to 6 cores

# Backtest Params
year=2022
month=
initialUsdc=1000
strategy="MacroUptrend"

# Ranges
upper_range=$(seq -0.5 -0.5 -5.0 | awk '{printf "%.2f\n", $1}')
middle_range=$(seq -5.0 -0.5 -10.0 | awk '{printf "%.2f\n", $1}')
lower_range=$(seq -10.0 -0.5 -15.0 | awk '{printf "%.2f\n", $1}')

count=0

for u in $upper_range; do
  for m in $middle_range; do
    for l in $lower_range; do
      u_target=$(echo "scale=2; $u-0.25" | bc)
      m_target=$(echo "scale=2; $m-0.25" | bc)
      l_target=$(echo "scale=2; $l-0.25" | bc)

      # Create safe filename
      job_id="combo-${u//./-}-${m//./-}-${l//./-}"
      
      # Create job YAML
      cat <<EOF > "$output_dir/${job_id}.yaml"
apiVersion: batch/v1
kind: Job
metadata:
  name: backtest-${job_id}
spec:
  backoffLimit: 2
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: backtester
        image: emabhiza/webistecs-backtest:test-0.0.16
        resources:
          requests:
            cpu: "$cpu_request"
            memory: "$memory_request"
          limits:
            cpu: "$cpu_limit"
            memory: "$memory_limit"
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: Development
        - name: LOCAL_RESULTS_PATH
          value: "/host-output"
        - name: BacktestParameters__Year
          value: "$year"
        - name: BacktestParameters__Month
          value: "$month"
        - name: BacktestParameters__InitialUsdc
          value: "$initialUsdc"
        - name: BacktestParameters__Strategy
          value: "$strategy"
        - name: BacktestParameters__Combo_Upper_Start
          value: "$u"
        - name: BacktestParameters__Combo_Upper_EndValue
          value: "$(echo "$u - 0.5" | bc)"
        - name: BacktestParameters__Combo_Upper_Target
          value: "$u_target"
        - name: BacktestParameters__Combo_Upper_Weight
          value: "5"
        - name: BacktestParameters__Combo_Middle_Start
          value: "$m"
        - name: BacktestParameters__Combo_Middle_EndValue
          value: "$(echo "$m - 0.5" | bc)"
        - name: BacktestParameters__Combo_Middle_Target
          value: "$m_target"
        - name: BacktestParameters__Combo_Middle_Weight
          value: "10"
        - name: BacktestParameters__Combo_Lower_Start
          value: "$l"
        - name: BacktestParameters__Combo_Lower_EndValue
          value: "$(echo "$l - 0.5" | bc)"
        - name: BacktestParameters__Combo_Lower_Target
          value: "$l_target"
        - name: BacktestParameters__Combo_Lower_Weight
          value: "15"
        volumeMounts:
        - name: pricedata-volume
          mountPath: /app/Resources
          readOnly: true
        - name: result-volume
          mountPath: /app/backtest-results
        - name: host-results
          mountPath: /host-output
      volumes:
      - name: pricedata-volume
        persistentVolumeClaim:
          claimName: pricedata-test-pvc
      - name: result-volume
        persistentVolumeClaim:
          claimName: backtest-results-pvc
      - name: host-results
        hostPath:
          path: "/Users/emabhiza/Dev/webistecs-storage/backtest-results"
          type: DirectoryOrCreate
EOF
      ((count++))
    done
  done
done

echo "✅ Generated $count Job YAMLs in $output_dir"