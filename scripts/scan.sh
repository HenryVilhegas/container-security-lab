#!/usr/bin/env bash
# Roda o Trivy (via container) nas duas imagens e gera relatórios + tabela antes/depois.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p reports
DATE=$(date +%F)
TRIVY="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache aquasec/trivy:latest"

count() { # $1=imagem $2=severidade
  $TRIVY image --quiet --scanners vuln --severity "$2" --format json "$1" \
    | python3 -c 'import sys,json; d=json.load(sys.stdin); print(sum(len(r.get("Vulnerabilities") or []) for r in d.get("Results",[])))'
}

for img in csl-insecure:1.0 csl-hardened:1.0; do
  name=${img%%:*}
  $TRIVY image --scanners vuln --severity HIGH,CRITICAL "$img" > "reports/${name}-${DATE}.txt"
done

{
  echo "Scan em $DATE (Trivy aquasec/trivy:latest)"
  echo
  echo "| Imagem | CRITICAL | HIGH | Tamanho |"
  echo "|---|---|---|---|"
  for img in csl-insecure:1.0 csl-hardened:1.0; do
    size=$(docker image inspect "$img" --format '{{.Size}}' | awk '{printf "%.0f MB", $1/1000000}')
    echo "| $img | $(count "$img" CRITICAL) | $(count "$img" HIGH) | $size |"
  done
} | tee "reports/summary-${DATE}.md"
