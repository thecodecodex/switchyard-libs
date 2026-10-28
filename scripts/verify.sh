#!/usr/bin/env bash
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

echo "=== Verificando integridade dos pacotes em switchyard-libs ==="

node -e '
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const manifest = JSON.parse(fs.readFileSync("manifest.json", "utf8"));
let hasError = false;

for (const [toolName, tool] of Object.entries(manifest.toolchains)) {
  console.log(`\n🔍 ${toolName} (${tool.distribuicao} ${tool.versao}):`);
  for (const [platform, pkg] of Object.entries(tool.plataformas)) {
    const dest = path.join(process.cwd(), pkg.arquivo);
    if (!fs.existsSync(dest)) {
      console.log(`  ✘ [AUSENTE] ${platform}: ${pkg.arquivo}`);
      hasError = true;
      continue;
    }
    const sum = execSync(`shasum -a 256 "${dest}"`).toString().split(" ")[0].trim();
    if (sum.toLowerCase() === pkg.sha256.toLowerCase()) {
      console.log(`  ✓ [OK] ${platform}: ${pkg.arquivo}`);
    } else {
      console.log(`  ✘ [CORROMPIDO] ${platform}: ${pkg.arquivo} (Esperado ${pkg.sha256}, obtido ${sum})`);
      hasError = true;
    }
  }
}

if (hasError) {
  console.error("\n❌ Foram encontrados erros na validação.");
  process.exit(1);
} else {
  console.log("\n✅ Todos os pacotes existentes estão íntegros.");
}
'
