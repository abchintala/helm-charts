{{- define "lib.configmap" }}
{{- if .Values.volumes.configMap }}
{{- range .Values.volumes.configMap }}
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: {{ .configMapName }}
data:
  {{ .fileName }}: |-
{{- (tpl .fileContent $)  | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
