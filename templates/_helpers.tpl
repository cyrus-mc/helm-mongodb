{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "shortname" -}}
{{- $name := default .Release.Name .Values.Name -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create the name for the admin secret.
*/}}
{{- define "adminSecret" -}}
    {{- if .Values.auth.existingAdminSecret -}}
        {{- .Values.auth.existingAdminSecret -}}
    {{- else -}}
        {{- template "fullname" . -}}-admin
    {{- end -}}
{{- end -}}

{{/*
Create the name for the key secret.
*/}}
{{- define "keySecret" -}}
    {{- if .Values.auth.existingKeySecret -}}
        {{- .Values.auth.existingKeySecret -}}
    {{- else -}}
        {{- template "fullname" . -}}-keyfile
    {{- end -}}
{{- end -}}

{{- define "database-scheduling" -}}
affinity:
{{- if .Values.Scheduling.rules.nodeAffinity }}
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:

{{- range $i := .Values.Scheduling.rules.nodeAffinity }}
        - key: {{ $i.key }}
          operator: In
          values:
{{- if eq $i.value ".Release.Namespace" }}
          - {{ $.Release.Namespace -}}
{{ else }}
          - {{ $i.value -}}
{{ end -}}
{{ end }}

{{- end }}

{{- if .Values.Scheduling.rules.podAntiAffinity }}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:

{{- range $i := .Values.Scheduling.rules.podAntiAffinity.matchExpressions }}
        - key: {{ $i.key }}
          operator: In
          values:
          - {{ $i.value -}}
{{ end }}
      topologyKey: '{{ .Values.Scheduling.rules.podAntiAffinity.topologyKey }}'
{{- end }}

{{- end }}
