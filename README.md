# Family Album Backup

Automated Docker container for backing up photos and videos from Mitene/Family Album services.

## Overview

Simple wrapper around the excellent mitene_download Python script

Related Projects:

- mitene_download - The underlying Python script (https://github.com/perrinjerome/mitene_download) all credit
- fammich - Advanced version with Immich integration (https://github.com/ChrisTracy/fammich)


## Features

- Multi-architecture Docker images (AMD64/ARM64)
- Automated dependency updates with Renovate
- GitHub Container Registry integration
- Secure non-root container execution
- File summary reporting (images, videos, comments)
- Optional Discord webhook notifications


## Environment Variables

| Variable | Required | Default | Description |
| :-- | :-- | :-- | :-- |
| MITENE_URL | Yes | - | Your family album URL |
| MITENE_PASSWORD | No | - | Album password (if required) |
| NO_COMMENTS | No | false | Exclude comment files |
| OUTPUT_DIR | No | /backup | Output directory |
| ENABLE_DISCORD_WEBHOOK | No | false | Enable Discord notifications |
| DISCORD_WEBHOOK_URL | No | - | Discord webhook URL |

## Kubernetes Example

### CronJob

    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: family-backup-cronjob
    spec:
      schedule: "0 16 * * 3"  # Wednesday at 4 PM
      timeZone: "Europe/London"
      successfulJobsHistoryLimit: 7
      failedJobsHistoryLimit: 3
      concurrencyPolicy: Forbid
      jobTemplate:
        spec:
          ttlSecondsAfterFinished: 259200
          backoffLimit: 2
          template:
            spec:
              restartPolicy: OnFailure
              securityContext:
                runAsNonRoot: true
                runAsUser: 65534
                runAsGroup: 65534
                fsGroup: 65534
                seccompProfile:
                  type: RuntimeDefault
              containers:
              - name: family-backup
                image: ghcr.io/andrewdavies-net/family-album-backup:latest
                securityContext:
                  allowPrivilegeEscalation: false
                  readOnlyRootFilesystem: true
                  runAsNonRoot: true
                  runAsUser: 65534
                  runAsGroup: 65534
                  capabilities:
                    drop: [ALL]
                  seccompProfile:
                    type: RuntimeDefault
                env:
                - name: MITENE_URL
                  valueFrom:
                    secretKeyRef:
                      name: family-backup-secret
                      key: mitene-url
                - name: MITENE_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: family-backup-secret
                      key: mitene-password
                - name: NO_COMMENTS
                  value: "false"
                - name: ENABLE_DISCORD_WEBHOOK
                  value: "false"  # Set to "true" to enable
                - name: DISCORD_WEBHOOK_URL
                  valueFrom:
                    secretKeyRef:
                      name: family-backup-secret
                      key: discord-webhook-url
                      optional: true
                volumeMounts:
                - name: backup-storage
                  mountPath: /backup
                - name: tmp-volume
                  mountPath: /tmp
                resources:
                  requests:
                    memory: "512Mi"
                    cpu: "200m"
                  limits:
                    memory: "2Gi"
                    cpu: "1000m"
              volumes:
              - name: backup-storage
                persistentVolumeClaim:
                  claimName: family-backup-pvc
              - name: tmp-volume
                emptyDir: {}
    
### PersistentVolumeClaim

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: family-backup-pvc
      namespace: cron-jobs
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Gi
      storageClassName: longhorn  # Adjust for your cluster
    
### Secret

    apiVersion: v1
    kind: Secret
    metadata:
      name: family-backup-secret
      namespace: cron-jobs
    type: Opaque
    stringData:
      mitene-url: "https://mitene.us/f/your-family-id"
      mitene-password: "your-password"
      discord-webhook-url: "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
    
## Quick Commands

Manual trigger:

    kubectl create job --from=cronjob/family-backup-cronjob manual-backup-$(date +%s) -n cron-jobs
    Check logs:

    kubectl logs -f job/manual-backup-xxx -n cron-jobs
    View file summary:

    kubectl exec job/manual-backup-xxx -n cron-jobs -- ls -la /backup
    
## Output

The container provides detailed file summaries:

    File Summary:
    ==================
    Images:   248
    Videos:   13  
    Comments: 159
    Total:    420
    ==================
    New files downloaded: 6
    
## Docker Usage

    docker run --rm -v /local/backup:/backup \
      -e MITENE_URL="https://mitene.us/f/your-family-id" \
      -e MITENE_PASSWORD="your-password" \
      ghcr.io/andrewdavies-net/family-album-backup:latest
    
