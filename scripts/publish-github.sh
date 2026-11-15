#!/bin/zsh
set -eu
cd "${0:A:h:h}"
# Run from a normal Terminal with access to your existing GitHub credentials.
git fetch origin main
if ! git merge-base HEAD origin/main >/dev/null 2>&1; then
  git merge --allow-unrelated-histories -s ours origin/main -m 'Connect standalone project to initialized GitHub repository'
fi
git push -u origin main
