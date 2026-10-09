# Deployment

## Public website

The connected Vercel project is `keepline`.
Its root is `site`. It runs `npm ci` and `npm run build`.
Vite places static assets in `site/dist`.
The site needs no environment variables, backend, account provider, or database.

The Vercel project uses the available free plan defaults.
The release does not enable paid build machines, databases, domains, or add-ons.

GitHub is the source of record. Production must use the merged commit from `main`.
Record the deployment identifier and source commit in `docs/RELEASE.md` after activation.
Check the public page, setup link, draft save, reload, clear, and storage-failure message.

`site/vercel.json` supplies security headers. The site self-hosts its font.
Preview deployments can have account protection. Verify production through its public domain.

## iPhone application

Vercel cannot deploy an iOS widget to an iPhone.
Use the Apple steps in `APPLE-SETUP.md` for device signing and distribution.
GitHub CI checks the native code on a simulator.
CI does not activate App Store Connect, TestFlight, or device provisioning.

## Release procedure

1. Check the exact PR head against both CI jobs.
2. Push a backup branch for the pre-merge `main` commit.
3. Squash-merge the verified PR head.
4. Read the merged commit and its checks from GitHub.
5. Deploy that commit through the connected Vercel project.
6. Read the deployment result and source metadata.
7. Test the affected public website flows.
8. Record the evidence and any activation limits.
