{{/* webistecs.name */}}
{{- define "webistecs.name" -}}
{{- default .Chart.Name .Values.nameOverride }}
{{- end }}

{{/* webistecs.fullname */}}
{{- define "webistecs.fullname" -}}
{{- if .Values.nameOverride }}
{{- .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "webistecs" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* webistecs.labels */}}
{{- define "webistecs.labels" -}}
app.kubernetes.io/name: {{ include "webistecs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/component: web
app.kubernetes.io/part-of: {{ .Chart.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* webistecs.selectorLabels */}}
{{- define "webistecs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webistecs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
