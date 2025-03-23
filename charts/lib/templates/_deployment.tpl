{{- define "lib.deployment" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "lib.fullname" . }}
  labels:
    {{- include "lib.labels" . | nindent 4 }}
spec:
  {{- if .Values.replicaCount }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "lib.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "lib.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets | default .Values.global.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "lib.serviceAccountName" . }}
      {{ if or .Values.hostAliases .Values.global.hostAliases }}
      {{- range or .Values.hostAliases .Values.global.hostAliases }}
      hostAliases:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          {{- if .Values.securityContext }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          {{- end }}
          image: "{{ .Values.image.repository | default .Values.global.image.repository }}/{{ .Values.service.name }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- if .Values.command }}
          command: 
          {{- range $.Values.command }}
          - {{ . | quote }}
          {{- end }}
          {{- end }}
          {{-  if .Values.args  }}
          args:
          {{- range $.Values.args }}
          - {{ . | quote }}
          {{-  end  }}
          {{- end }}
          ports:
          {{- range .Values.service.ports }}
          - name: {{ .name }}
            containerPort: {{ .targetPort }}
            protocol: {{ .protocol }}
          {{- end }}
          env:
          {{- if .Values.global.env }}
          {{- range $key, $val := .Values.global.env }}
          - name: {{ $key }}
            value: {{ $val | quote }}
          {{- end }}
          {{- end }}
          {{- if .Values.env }}
          {{- range $key, $val := .Values.env }}
          - name: {{ $key }}
            value: {{ $val | quote }}
          {{- end }}
          {{- end }}
          {{- if .Values.global.envSecrets }}
          {{- range .Values.global.envSecrets }}
          - name: {{ .name }}
            valueFrom:
              secretKeyRef:
                name: {{ .secretName }}
                key: {{ .key }}
          {{- end }}
          {{- end }}
          {{- if .Values.envSecrets }}
          {{- range .Values.envSecrets }}
          - name: {{ .name }}
            valueFrom:
              secretKeyRef:
                name: {{ .secretName }}
                key: {{ .key }}
          {{- end }}
          {{- end }}
          {{- if .Values.probe.enabled }}
          livenessProbe:
            httpGet:
              path: {{ .Values.livenessProbe.path }}
              port: {{ .Values.service.port }}
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds | default 5 }}
            timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds | default 10 }}
            failureThreshold: {{ .Values.livenessProbe.failureThreshold | default 20 }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds | default 5 }}
          readinessProbe:
            httpGet:
              path: {{ .Values.readinessProbe.path }}
              port: {{ .Values.service.port }}
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds | default 15 }}
            timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds | default 30 }}
            failureThreshold: {{ .Values.readinessProbe.failureThreshold | default 20 }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds | default 5 }}
          {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
          {{- if .Values.volumeMounts }}
            {{- range .Values.volumeMounts }}
          - name: {{ .name }}
            mountPath: {{ .mountPath }}
            subPath: {{ .subPath }}
            readOnly: {{ .readOnly }}
            {{- end }}
          {{- end }}
      volumes:
      {{- if .Values.volumes.persistentVolume }}
        {{- range .Values.volumes.persistentVolume }}
        - name: {{ .name }}
          persistentVolumeClaim:
            claimName: {{ .claimName }}
        {{- end }}
      {{- end }}
      {{- if .Values.volumes.configMap }}
        {{- range .Values.volumes.configMap }}
        - name: {{ .name }}
          configMap:
            defaultMode: {{ .defaultMode }}
            items:
            - key: {{ .key }}
              path: {{ .path }}
            name: {{ .configMapName }}
            optional: false
        {{- end }}
      {{- end }}
      {{- if .Values.volumes.secret }}
        {{- range .Values.volumes.secret }}
        -  name: {{ .name }}
           secret:
            secretName: {{ .secretName }}
        {{- end }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}