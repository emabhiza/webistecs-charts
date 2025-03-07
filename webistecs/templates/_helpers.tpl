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