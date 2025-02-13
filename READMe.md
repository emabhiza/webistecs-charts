# Kubernetes Configuration Files
This repository contains various Kubernetes configuration files used for deploying and managing components in a 
Kubernetes cluster. Below is an explanation of each file and a guide on how to apply them in the correct order.

# File Descriptions
## Storage and Provisioning
database-pv.yaml: Defines a PersistentVolume (PV) for the database, essentially creating a reserved space for database 
storage on physical disks that your applications can use.

database-pvc.yaml: Defines a PersistentVolumeClaim (PVC) for the database, which is like placing an order for a specific
amount of storage space, matched with the space provided by the PersistentVolume.

elasticsearch-pv.yaml: Sets up a PersistentVolume for Elasticsearch, ensuring dedicated storage for this tool that helps
in searching and analyzing large volumes of data.

elasticsearch-pvc.yaml: Creates a PersistentVolumeClaim for Elasticsearch, securing the necessary storage resources from
the available pool.

grafana-pv.yaml: Establishes a PersistentVolume for Grafana, which is used to store data that Grafana will use to
visualize metrics through dashboards.

grafana-pvc.yaml: Sets up a PersistentVolumeClaim for Grafana to formally request the needed storage capacity from the
system.

prometheus-pv.yaml: Defines a PersistentVolume for Prometheus, which is a monitoring tool that collects and stores
metrics as time series data.

prometheus-pvc.yaml: Establishes a PersistentVolumeClaim for Prometheus, allowing it to claim the required storage
space within the cluster.

nfs-storage.yaml: Defines an NFS (Network File System) server for managing shared storage across the network, making it
easier to handle and access data across different machines.

nfs-client-provisioner-deployment.yaml: Deploys an NFS client provisioner that automatically handles the setup of storage
spaces as needed by applications, reducing manual configuration tasks.

nfs-client-provisioner-role.yaml: Defines the permissions for the NFS client provisioner, allowing it to perform its tasks
within the cluster without security restrictions.

nfs-client-provisioner-rolebinding.yaml: Connects the permissions set in nfs-client-provisioner-role.yaml to the provisioner
itself, ensuring it operates under the right privileges.

# Monitoring and Logging
prometheus-configmap.yaml: Provides configuration settings for Prometheus, which include instructions on what data to collect
and how frequently, making it easier to monitor the health of applications.

prometheus-deployment.yaml: Deploys Prometheus, a tool that continuously gathers and stores operational metrics, offering
insights into the health and performance of various components.

prometheus-service.yaml: Makes Prometheus available as a service within the cluster, enabling other applications and services
to interact with it for monitoring purposes.

fluent-bit-configmap.yaml: Configures Fluent Bit to manage the collection and forwarding of log data, simplifying how logs
are handled and analyzed.

fluent-bit-daemonset.yaml: Deploys Fluent Bit across all nodes as a DaemonSet to ensure that log data is consistently
collected throughout the cluster.

fluent-bit-rbac.yaml: Sets up the necessary permissions for Fluent Bit to operate within the Kubernetes environment,
ensuring it can access the resources it needs to function effectively.

# Observability and Management
kibana-deployment.yaml: Deploys Kibana, a web-based interface that helps users to visualize and query the data stored
in Elasticsearch, making it easier to understand and analyze.

kibana-service.yaml: Exposes Kibana as a service within the cluster, allowing users to access Kibana through a web browser
from anywhere within the network.

elasticsearch-deployment.yaml: Deploys Elasticsearch, a powerful search and data analytics engine, which stores and manages
searchable data structures.

elasticsearch-service.yaml: Makes Elasticsearch available as a service, facilitating data access and interactions from various
parts of the cluster.

grafana-deployment.yaml: Deploys Grafana, which is a tool for creating attractive and informative graphical displays from various
data sources.

grafana-service.yaml: Exposes Grafana as a service, providing a web interface for users to create and view dashboards that display
data metrics in a comprehensible way.

1. Apply PersistentVolume and PersistentVolumeClaim for the Database:

```
kubectl apply -f database-pv.yaml
kubectl apply -f database-pvc.yaml
```
2. 
```
kubectl apply -f elasticsearch-pv.yaml
kubectl apply -f elasticsearch-pvc.yaml

kubectl apply -f grafana-pv.yaml
kubectl apply -f grafana-pvc.yaml

kubectl apply -f prometheus-pv.yaml
kubectl apply -f prometheus-pvc.yaml
```

3.
```
kubectl apply -f nfs-storage.yaml
kubectl apply -f nfs-client-provisioner-deployment.yaml
kubectl apply -f nfs-client-provisioner-role.yaml
kubectl apply -f nfs-client-provisioner-rolebinding.yaml
```

4. 
``` 
kubectl apply -f fluent-bit-configmap.yaml
kubectl apply -f fluent-bit-rbac.yaml
kubectl apply -f fluent-bit-daemonset.yaml

kubectl apply -f prometheus-configmap.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f prometheus-service.yaml
```
5. 
```

kubectl apply -f fluent-bit-configmap.yaml
kubectl apply -f fluent-bit-rbac.yaml
kubectl apply -f fluent-bit-daemonset.yaml

kubectl apply -f prometheus-configmap.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f prometheus-service.yaml
```
6.
```

kubectl apply -f elasticsearch-deployment.yaml
kubectl apply -f elasticsearch-service.yaml

kubectl apply -f kibana-deployment.yaml
kubectl apply -f kibana-service.yaml

kubectl apply -f grafana-deployment.yaml
kubectl apply -f grafana-service.yaml
```

7. To delete unnecessary pods
```
kubectl scale deployment webistecs-prometheus-pushgateway --replicas=0

kubectl scale deployment webistecs-alertmanager --replicas=0

kubectl delete deployment webistecs-kube-state-metrics
```


helm install argo-cd argo/argo-cd --namespace argocd --create-namespace --replace



kubectl patch pv local-usb-pv -p '{"spec":{"claimRef":{"namespace":"monitoring","name":"my-usb-pvc"}}}'
