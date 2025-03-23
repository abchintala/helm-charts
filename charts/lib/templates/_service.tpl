{{- define "lib.service" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "lib.fullname" . }}
  labels:
    {{- include "lib.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    {{- range .Values.service.ports }}
    - port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ .protocol }}
      name: {{ .name }}
    {{- end }}
  selector:
    {{- include "lib.selectorLabels" . | nindent 4 }}
{{- end }}