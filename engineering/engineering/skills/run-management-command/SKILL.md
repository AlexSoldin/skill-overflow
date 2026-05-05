---
name: run-management-command
description: Run a Django management command on Cloud Run (staging or production) by creating a one-off job, executing it, checking the result, and deleting the job.
---

# Run a Django management command on Cloud Run

Execute a one-off Django management command against a live environment (staging or production) using a Cloud Run job. The job is deleted after execution.

## Usage

```
/run-management-command
```

## Instructions

### 1. Gather inputs

Ask the user:

1. **Which command?** (e.g. `python manage.py backfill_assessable_objects --dry-run`)
2. **Which environment?** `staging` or `production`

### 2. Resolve environment config

| Environment | GCP project | Region | Cloud Run service |
|-------------|-------------|--------|-------------------|
| staging | `coolset-staging` | `europe-west3` | `pulse-app` |
| production | `coolset-production` | `europe-west3` | `pulse-app` |

### 3. Fetch the current image and service configuration

Pull the latest deployed image and configuration from the running Cloud Run service so the job runs the same code:

```bash
gcloud run services describe <service> \
  --project <project> --region <region> \
  --format json
```

Extract from the response:
- `spec.template.spec.containers[0].image` — the container image to use
- `spec.template.metadata.annotations["run.googleapis.com/cloudsql-instances"]` — Cloud SQL connection string
- `spec.template.metadata.annotations["run.googleapis.com/vpc-access-connector"]` — VPC connector
- `spec.template.spec.serviceAccountName` — service account
- `spec.template.spec.containers[0].env` — all env vars

**Important — secret env vars:** Cloud Run services use secret *aliases* (e.g. `secret-alias-anthropic-api-key`) which are scoped to the service and not directly usable in jobs. The actual secret names are in the annotation `run.googleapis.com/secrets` on the service template, which maps alias → real secret name. Parse this annotation to build the correct `--set-secrets` flags for the job.

The annotation looks like:
```
PULSE_ANTHROPIC_API_KEY=secret-alias-anthropic-api-key:latest,DATABASE_URL=secret-alias-database-url:latest,...
```

Each entry is `ENV_VAR=alias:version`. Look up each alias in the secrets annotation to get the real GCP secret name, then format as `ENV_VAR=REAL_SECRET_NAME:latest`.

### 4. Create the Cloud Run job

```bash
gcloud beta run jobs create <job-name> \
  --project <project> \
  --region <region> \
  --image <image> \
  --service-account <service-account> \
  --set-cloudsql-instances <cloudsql-connection-string> \
  --vpc-connector <vpc-connector> \
  --set-env-vars <non-secret-env-vars> \
  --set-secrets <secret-env-vars> \
  --command "python" \
  --args "manage.py,<subcommand>,<arg1>,<arg2>" \
  --max-retries 0 \
  --task-timeout 3600
```

Job naming convention: use the management command name with hyphens, e.g. `backfill-assessable-objects`.

**Notes:**
- `--command` and `--args` override the image's default entrypoint
- Split the management command into `--command python` and `--args manage.py,<rest>` (comma-separated, no spaces)
- `--max-retries 0` prevents accidental double-runs for data mutations
- Omit plain env vars that are already covered by `--set-secrets`

### 5. Confirm before executing

Show the job name and full command, then ask:

> "Job `<job-name>` created with command `<command>`. Execute it now?"

### 6. Execute the job and wait

```bash
gcloud beta run jobs execute <job-name> \
  --project <project> \
  --region <region> \
  --wait
```

`--wait` blocks until the job finishes and exits non-zero on failure.

### 7. Check the result

```bash
gcloud beta run jobs executions list \
  --job <job-name> \
  --project <project> \
  --region <region> \
  --limit 1
```

Confirm the execution shows `COMPLETE 1 / 1`. If it shows a failure, fetch logs:

```bash
gcloud beta run jobs executions logs <execution-name> \
  --project <project> \
  --region <region>
```

### 8. Delete the job

One-off jobs should not linger. Delete after a successful run:

```bash
gcloud beta run jobs delete <job-name> \
  --project <project> \
  --region <region> \
  --quiet
```

### 9. Report completion

> "Job `<job-name>` executed successfully and deleted. Execution: `<execution-name>`."

## Safety rules

- **Always delete the job after execution** — Cloud Run jobs are one-off; leaving them creates clutter and risk of accidental re-runs.
- **Default `--max-retries 0`** for data mutations — retries can cause duplicate writes.
- **Never run against production without explicit confirmation** — restate the project name before executing.
- **Use `--dry-run` first** when the management command supports it, and share the output with the user before running for real.
