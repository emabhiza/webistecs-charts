{{/* Define 'webistecs.fullname' template */}}
{{- define "webistecs.fullname" -}}
{{- default .Chart.Name .Values.webistecs.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Generate basic labels for Webistecs */}}
{{- define "webistecs.labels" -}}
app.kubernetes.io/name: {{ include "webistecs.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Selector labels for Webistecs */}}
{{- define "webistecs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webistecs.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/* Define 'grafana.fullname' template */}}
{{- define "grafana.fullname" -}}
{{- default .Chart.Name .Values.grafana.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Generate basic labels */}}
{{- define "grafana.labels" -}}
app.kubernetes.io/name: {{ include "grafana.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Selector labels */}}
{{- define "grafana.selectorLabels" -}}
app.kubernetes.io/name: {{ include "grafana.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/* Define 'prometheus.fullname' template */}}
{{- define "prometheus.fullname" -}}
{{- default .Chart.Name .Values.prometheus.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Generate basic labels for Prometheus */}}
{{- define "prometheus.labels" -}}
app.kubernetes.io/name: {{ include "prometheus.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/* Selector labels for Prometheus */}}
{{- define "prometheus.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

