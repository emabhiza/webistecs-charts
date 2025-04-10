#!/bin/bash

# Configuration
MAX_JOBS=10            # Concurrent jobs
JOB_FILES_DIR="./generated-jobs"
RESULTS_DIR="./results"
LOG_FILE="${RESULTS_DIR}/job-runner.log"

# Setup
mkdir -p "$RESULTS_DIR"
echo "$(date) - Job runner started" >> "$LOG_FILE"

# Process all generated job files
for job_file in "${JOB_FILES_DIR}"/*.yaml; do
  # Wait for available slot
  while [ "$(kubectl get jobs -o json | jq -r '.items[] | select(.status.active==1) | .metadata.name' | wc -l)" -ge "$MAX_JOBS" ]; do
    echo "$(date) - Waiting for job slots..." | tee -a "$LOG_FILE"
    sleep 10
  done

  # Submit job
  job_name=$(basename "$job_file" .yaml)
  echo "$(date) - Starting job: $job_name" | tee -a "$LOG_FILE"
  
  kubectl apply -f "$job_file" >> "$LOG_FILE" 2>&1
  
  # Track started jobs
  echo "$job_name,$(date +%s)" >> "${RESULTS_DIR}/jobs-started.csv"
done

# Final monitoring
echo "$(date) - All jobs submitted. Waiting for completion..." | tee -a "$LOG_FILE"

while [ "$(kubectl get jobs -o json | jq -r '.items[] | select(.status.succeeded==null and .status.failed==null) | .metadata.name' | wc -l)" -gt 0 ]; do
  remaining=$(kubectl get jobs -o json | jq -r '.items[] | select(.status.succeeded==null and .status.failed==null) | .metadata.name' | wc -l)
  echo "$(date) - Jobs remaining: $remaining" | tee -a "$LOG_FILE"
  sleep 30
done

# Generate final report
echo "$(date) - All jobs completed" | tee -a "$LOG_FILE"
kubectl get jobs > "${RESULTS_DIR}/jobs-final-report.txt"

# Cleanup successful jobs (optional)
kubectl delete jobs --field-selector status.successful=1

echo "✅ All done! Results in $RESULTS_DIR" | tee -a "$LOG_FILE"