# DevOps Task — CI/CD Pipeline for a Serverless App (GitLab + AWS)

## Objective

Build a **GitLab CI/CD pipeline** for the `hello-sam` serverless application that, on every commit, validates the app, deploys it to **two environments (INT and PROD)**, smoke-tests each, and notifies a **Telegram** chat of the result — with a **manual promotion** gate from INT to PROD.

## Environment

- **Local GitLab** with a **GitLab Runner** (Docker executor)
- An **AWS account** (sandbox) as the AWS environment
- Tooling: SAM CLI, AWS CLI, .NET SDK, Docker, `make`

## What to build

### 1. Pipeline structure

A pipeline with the following logical stages:

```
validate → deploy INT → smoke INT → [manual gate] → deploy PROD → smoke PROD → notify
```

### 2. Validation stage

On every commit, build the application and validate the SAM template. The pipeline must **fail fast** if either fails, and never attempt a deploy.

### 3. Two environments

Deploy to two distinct environments:

- **INT** — deployed automatically on every passing commit.
- **PROD** — deployed only after an explicit, **manual** promotion.

Represent both as GitLab **environments** so their state is tracked and reviewable.

### 4. Smoke tests

After each deploy, run an automated smoke test that hits the deployed endpoint and asserts the expected response. A failed smoke test must block the pipeline (and, for INT, block promotion to PROD).

### 5. Promotion gate

The INT → PROD transition must be a **manual** approval step. It must be *impossible* to trigger PROD deploy unless INT's smoke test passed.

### 6. Telegram notifications

Notify a Telegram chat on pipeline success and failure (use the Telegram Bot API). Prefer a single reusable notify job rather than duplicating logic per stage.

### 7. (Bonus) Rollback

Add a way to roll back PROD to the previous working version.

## Approach guidance (preferred, not required)

- Use **one parametrized deploy job** reused by both environments (via CI variables), rather than two near-identical jobs.
- Drive the promotion gate with GitLab's **manual (`when: manual`) + dependency (`needs`)** semantics.
- Use a **Docker-based runner image** that already contains the required tools; avoid installing tools in every job.
- Store AWS credentials as **masked + protected** CI/CD variables; never hardcode them in the pipeline.
- For notifications, prefer a single `notify` job with Telegram Bot credentials stored as CI variables.

## Deliverables

1. GitLab repo containing the pipeline definition and the smoke-test script.
2. A screenshot of a **green pipeline** (validate → INT → smoke INT → PROD → smoke PROD → notify).
3. The **PROD API URL** and proof it works.
4. A short written explanation (3–4 sentences) of why the promotion is manual and what would need to change to make it fully automatic.

## Acceptance criteria

- A broken commit fails at `validate` and never deploys.
- INT auto-deploys on green commits; PROD requires a manual click.
- A failing INT smoke test prevents PROD deployment.
- Both environments appear under GitLab's **Environments** page.
- Success and failure messages arrive in Telegram.

## Hints (only if stuck)

- Deploying requires **IAM capabilities including `CAPABILITY_NAMED_IAM`** (the execution role has a fixed name).
- Both INT and PROD stacks need an execution role; think about whether they can share one and how to structure that.
- The runner must have `make` available, not just the SAM/AWS CLIs.
