# Introduction

This is the source for my personal [site](https://jsevedge.github.io).  The SSG is [Hugo](https://gohugo.io).

## Prerequisites

- Pull in git submodules: `git submodule update --init --recursive`
- Install hugo: `brew install hugo` (or your package manager of choice)

## Usage

- Make changes (Add a blog post, change the theme, etc.)
- Validate changes locally: `hugo server`
- Run prose linter: `proselint content/*`
- Publish to [jsevedge.github.io](https://jsevedge.github.io): `./scripts/deploy.sh`
- Save source changes to this repo using standard git flow

