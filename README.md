# Introduction

This is the source for my personal [site](https://jamessevedge.com).  The SSG is [Hugo](https://gohugo.io).

## Prerequisites

- Pull in git submodules: `git submodule update --init --recursive`
- Install hugo: `brew install hugo` (or your package manager of choice)

## Usage

- Make changes (Add a blog post, change the theme, etc.)
- Validate changes locally: `hugo server`
- Run prose linter: `proselint content/*`
- Output Jupyter Notebook html (optional): `./scripts/execute_notebooks.sh`
- Publish to Github Pages ([jamessevedge.com](https://jamessevedge.com)): `./scripts/deploy.sh`
- Save source changes to this repo using standard git flow
