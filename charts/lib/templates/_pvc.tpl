{{- define "lib.pvc" }}
{{- if .Values.pvc.enabled }}
{{- range .Values.pvc.definitions }}
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ .name }}
  annotations:
  {{- if .storageClass }}
    volume.beta.kubernetes.io/storage-class: {{ .storageClass | quote }}
  {{- else }}
    volume.alpha.kubernetes.io/storage-class: default
  {{- end }}
spec:
  accessModes:
    - {{ .accessMode | quote }}
  resources:
    requests:
      storage: {{ .size | quote }}
{{ end }}
{{ end }}
{{ end }}