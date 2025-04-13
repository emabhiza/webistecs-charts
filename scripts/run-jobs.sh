#!/bin/bash

# Configuration
MAX_JOBS=1
JOB_FILES_DIR="./generated-jobs"
RESULTS_DIR="./backtest-results"
LOG_FILE="job-runner-$(date +%Y%m%d-%H%M%S).log"
MAX_PENDING_PODS=5  # Threshold to throttle submissions
HEALTH_CHECK_INTERVAL=15  # Seconds between cluster checks

# Toggle for testing only 3 jobs
TEST_MODE=true   # <--- Set to false to run all jobs
TEST_JOB_LIMIT=3

# Cluster monitoring functions
check_cluster_health() {
  # Get cluster resource status
  kubectl get nodes --no-headers | awk '{print $1}' | while read node; do
    echo "=== Node $node Status ==="
    kubectl describe node $node | grep -A 10 "Allocated resources:"
  done

  # Check for system pods health
  kubectl get pods -n kube-system --no-headers | grep -v Running
}

resource_check() {
  # Check if we should pause submissions due to cluster load
  local pending_pods=$(kubectl get pods -A --field-selector=status.phase=Pending -o json | jq '.items | length')
  local failed_jobs=$(kubectl get jobs --field-selector=status.failed>=1 -o json | jq '.items | length')
  
  if [ "$pending_pods" -gt $MAX_PENDING_PODS ]; then
    echo "Cluster overload: $pending_pods pods pending (threshold: $MAX_PENDING_PODS)" | tee -a "$LOG_FILE"
    return 1
  fi
  
  if [ "$failed_jobs" -gt $((MAX_JOBS/2)) ]; then
    echo "Warning: $failed_jobs jobs failed - possible cluster issues" | tee -a "$LOG_FILE"
    return 1
  fi
  
  return 0
}

# Setup
mkdir -p "$RESULTS_DIR"
echo "=== Job Runner Started $(date) ===" | tee -a "$LOG_FILE"
echo "Max Concurrent Jobs: $MAX_JOBS" | tee -a "$LOG_FILE"
echo "Max Pending Pods Threshold: $MAX_PENDING_PODS" | tee -a "$LOG_FILE"
echo "Results will be saved in: $RESULTS_DIR" | tee -a "$LOG_FILE"

# Initial cluster health check
echo "=== Initial Cluster Status ===" | tee -a "$LOG_FILE"
check_cluster_health | tee -a "$LOG_FILE"

# Cleanup old completed jobs and pods
echo "Cleaning up completed jobs and pods..." | tee -a "$LOG_FILE"
kubectl delete jobs --field-selector status.successful=1 --wait=false 2>/dev/null
kubectl delete pods --field-selector status.phase==Succeeded --wait=false 2>/dev/null

# Submit jobs with cluster health monitoring
count=0
for job_file in "$JOB_FILES_DIR"/*.yaml; do
  # If in test mode, limit to TEST_JOB_LIMIT jobs
  if [ "$TEST_MODE" = true ] && [ "$count" -ge "$TEST_JOB_LIMIT" ]; then
    echo "Test mode active - skipping remaining jobs" | tee -a "$LOG_FILE"
    break
  fi

  # Wait for available resources
  while true; do
    # Check running jobs
    running_jobs=$(kubectl get jobs -o json | jq '[.items[] | select(.status.active==1)] | length')
    
    # Check cluster health
    if resource_check; then
      # Proceed if we're below max jobs and cluster is healthy
      [ "$running_jobs" -lt "$MAX_JOBS" ] && break
    fi
    
    # Show status while waiting
    echo "[$(date +%T)] Waiting for resources (Running: $running_jobs/$MAX_JOBS)" | tee -a "$LOG_FILE"
    sleep $HEALTH_CHECK_INTERVAL
  done

  job_name=$(basename "$job_file" .yaml)
  echo "Submitting job $((++count)): $job_name" | tee -a "$LOG_FILE"
  kubectl apply -f "$job_file" | tee -a "$LOG_FILE"
  
  # Small delay between submissions to avoid burst
  sleep 2
done

echo "=== All jobs submitted ($count total) ===" | tee -a "$LOG_FILE"
echo "=== Waiting for completion... ===" | tee -a "$LOG_FILE"

# Enhanced completion waiting with cluster health checks
while true; do
  running_jobs=$(kubectl get jobs -o json | jq '[.items[] | select(.status.succeeded==null and .status.failed==null)] | length')
  [ "$running_jobs" -eq 0 ] && break
  
  # Periodically check cluster health during wait
  if [ $(( $(date +%s) % 120 )) -eq 0 ]; then  # Every 2 minutes
    echo "=== Periodic Cluster Status ===" | tee -a "$LOG_FILE"
    check_cluster_health | tee -a "$LOG_FILE"
  fi
  
  echo "[$(date +%T)] Jobs still running: $running_jobs" | tee -a "$LOG_FILE"
  sleep $HEALTH_CHECK_INTERVAL
done

# Final cleanup and reporting
echo "=== All jobs completed ===" | tee -a "$LOG_FILE"

echo "=== Final Job Status ===" | tee -a "$LOG_FILE"
kubectl get jobs | tee -a "$LOG_FILE"

echo "=== Failed Jobs (if any) ===" | tee -a "$LOG_FILE"
kubectl get jobs --field-selector=status.failed>=1 | tee -a "$LOG_FILE"

echo "Cleaning up completed jobs and pods..." | tee -a "$LOG_FILE"
kubectl delete jobs --field-selector status.successful=1 --wait=false 2>/dev/null
kubectl delete pods --field-selector status.phase==Succeeded --wait=false 2>/dev/null

echo "=== Final Cluster Status ===" | tee -a "$LOG_FILE"
check_cluster_health | tee -a "$LOG_FILE"

echo "✅ Done! Results are in $RESULTS_DIR" | tee -a "$LOG_FILE"
echo "Total jobs executed: $count" | tee -a "$LOG_FILE"