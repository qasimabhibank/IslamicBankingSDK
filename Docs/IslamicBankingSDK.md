# IslamicBankingSDK — Developer Guide

> Prefer [GettingStarted.md](GettingStarted.md) and [API.md](API.md) for day-to-day integration.  
> This page is a short overview of the standalone package.

## What this SDK is

A **self-contained** UIKit Swift Package that ships:

- Murabaha financing screens (storyboard + XIBs + assets)
- View models / models
- Public configure + start API
- Optional built-in `URLSession` networking

It does **not** depend on FINCAPay, CocoaPods, or any host app classes.

## Integration summary

1. Add package from GitHub (see README)
2. `IslamicBanking.configure(...)`
3. `IslamicBanking.startFlow(from:)`

## Screens

1. Murabaha financing intro  
2. My proposals  
3. Proposal details (declaration / invoice / offer)  
4. Completed proposal + repayment schedule  
5. Success + All Set popup  
6. Optional account-creation / CNIC (included in package)

## Publish

See [PUBLISH.md](PUBLISH.md) to push this folder as its own GitHub repository.
