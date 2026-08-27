# Publish IslamicBankingSDK to GitHub

This folder (`IslamicBankingSDK/`) is a **complete standalone Swift package**.  
Upload **this folder as the root** of a new GitHub repository (not the whole FINCAPay app).

---

## Option A — New repo from this folder (recommended)

```bash
# 1) Go into the package root
cd /path/to/FINCAPay-iOS/IslamicBankingSDK

# 2) Init git (only if this folder is not already its own repo)
git init
git add .
git commit -m "Initial release of IslamicBankingSDK 1.0.0"

# 3) Create empty GitHub repo (no README), then:
git branch -M main
git remote add origin https://github.com/YOUR_ORG/IslamicBankingSDK.git
git push -u origin main

# 4) Tag the first version (required for SPM "from: 1.0.0")
git tag 1.0.0
git push origin 1.0.0
```

Or with GitHub CLI:

```bash
cd /path/to/FINCAPay-iOS/IslamicBankingSDK
gh repo create YOUR_ORG/IslamicBankingSDK --public --source=. --remote=origin --push
git tag 1.0.0 && git push origin 1.0.0
```

---

## Option B — Keep living inside FINCAPay-iOS

Consumers can still add a **local** package path, but GitHub SPM users need a **dedicated repo** (Option A).

You may keep a copy inside FINCAPay for development and push the same tree to GitHub.

---

## After publishing — consumers install with

```text
https://github.com/YOUR_ORG/IslamicBankingSDK.git
```

Replace `YOUR_ORG` in:

- `README.md`
- `CHANGELOG.md`
- this file

---

## Checklist before first tag

- [ ] `Package.swift` resolves (`swift package describe`)
- [ ] Xcode can build for iOS
- [ ] README shows correct GitHub URL
- [ ] LICENSE chosen (MIT included; change if needed)
- [ ] No secrets (tokens, production app keys) committed
- [ ] Tag `1.0.0` pushed

---

## Releasing a new version

```bash
# update CHANGELOG.md, then:
git add .
git commit -m "Release 1.1.0"
git tag 1.1.0
git push origin main --tags
```

SPM clients on `from: "1.0.0"` will pick up compatible versions automatically.
