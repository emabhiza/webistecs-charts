#!/bin/bash

# Configuration
output_dir="$(dirname "$0")/generated-jobs"
mkdir -p "$output_dir"

# Resource configuration
memory_request="1.5Gi"
memory_limit="3Gi"
cpu_request="500m"
cpu_limit="1"

# Ranges with precision control
upper_range=$(seq -0.5 -0.5 -5.0 | awk '{printf "%.2f\n", $1}')
middle_range=$(seq -5.0 -0.5 -10.0 | awk '{printf "%.2f\n", $1}')
lower_range=$(seq -10.0 -0.5 -15.0 | awk '{printf "%.2f\n", $1}')

# Backtest parameters
year=2022
month=1
initialUsdc=1000
strategy="MacroUptrend"

count=0

# Generate job files
for u in $upper_range; do
  for m in $middle_range; do
    for l in $lower_range; do
      # Calculate targets with bc's scale=2 for consistency
      u_target=$(echo "scale=2; ($u + ($u - 0.5))/2" | bc)
      m_target=$(echo "scale=2; ($m + ($m - 0.5))/2" | bc)
      l_target=$(echo "scale=2; ($l + ($l - 0.5))/2" | bc)

      # Create safe identifier
      job_id="combo-${u//./-}-${m//./-}-${l//./-}"
      
      # Generate job file with all enhancements
      cat <<EOF > "$output_dir/${job_id}.yaml"
apiVersion: batch/v1
kind: Job
metadata:
  name: backtest-${job_id}
spec:
  backoffLimit: 2  # Retry failed jobs twice
  template:
    spec:
      containers:
      - name: backtester
        image: emabhiza/webistecs-backtest:test-0.0.2
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
      restartPolicy: OnFailure
      volumes:
      - name: pricedata-volume
        persistentVolumeClaim:
          claimName: pricedata-test-pvc
      - name: result-volume
        persistentVolumeClaim:
          claimName: backtest-results-pvc
      - name: host-results
        hostPath:
          path: /Users/emabhiza/Dev/webistecs-storage/backtest-results
          type: DirectoryOrCreate
EOF
      ((count++))
    done
  done
done

# Generate an enhanced runner script
cat <<EOF > "$output_dir/run-jobs.sh"
#!/bin/bash
# Auto-generated job runner
MAX_JOBS=3  # Safe for Rancher Desktop
LOG_FILE="job-execution-\$(date +%Y%m%d).log"
RESULTS_DIR="/Users/emabhiza/Dev/webistecs-storage/backtest-results"

# Ensure results directory exists
mkdir -p "\$RESULTS_DIR"
chmod 777 "\$RESULTS_DIR"

echo "=== Starting job batch \$(date) ===" | tee -a \$LOG_FILE
echo "Results will be saved to: \$RESULTS_DIR" | tee -a \$LOG_FILE

# Clean completed jobs
kubectl delete jobs --field-selector status.successful=1

find . -name "*.yaml" | while read -r job_file; do
  while [ \$(kubectl get jobs -o json | jq -r '.items[] | select(.status.active==1) | .metadata.name' | wc -l) -ge \$MAX_JOBS ]; do
    echo "[\$(date +%H:%M:%S)] Waiting for job slots..." | tee -a \$LOG_FILE
    sleep 10
  done
  
  job_name=\$(basename "\$job_file" .yaml)
  echo "=== Submitting \$job_name ===" | tee -a \$LOG_FILE
  kubectl apply -f "\$job_file" | tee -a \$LOG_FILE
  
  # Monitor this specific job
  (kubectl logs -f job/\$job_name --tail=1 2>&1 | grep -E 'Saved|Error') &
done

echo "=== Job submission complete ===" | tee -a \$LOG_FILE
echo "=== Monitoring remaining jobs ===" | tee -a \$LOG_FILE

while [ \$(kubectl get jobs -o json | jq -r '.items[] | select(.status.succeeded==null and .status.failed==null) | .metadata.name' | wc -l) -gt 0 ]; do
  remaining=\$(kubectl get jobs -o json | jq -r '.items[] | select(.status.succeeded==null and .status.failed==null) | .metadata.name' | wc -l)
  echo "[\$(date +%H:%M:%S)] Jobs remaining: \$remaining" | tee -a \$LOG_FILE
  sleep 30
done

echo "=== All jobs completed ===" | tee -a \$LOG_FILE
echo "=== Final results in \$RESULTS_DIR ===" | tee -a \$LOG_FILE
ls -la "\$RESULTS_DIR" | tee -a \$LOG_FILE
EOF

chmod +x "$output_dir/run-jobs.sh"

echo "✅ Successfully generated:"
echo "- $count backtest job YAML files"
echo "- Enhanced run-jobs.sh controller script"
echo "- All output will be saved to:"
echo "  • Kubernetes PVC: /app/backtest-results"
echo "  • Your Mac: /Users/emabhiza/Dev/webistecs-storage/backtest-results"
echo ""
echo "To execute:"
echo "1. cd $output_dir"
echo "2. ./run-jobs.sh"