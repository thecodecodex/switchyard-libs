#!/usr/bin/env bash
set -euo pipefail

# Diretório raiz do repositório
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

echo "=== Sincronizando pacotes de toolchains para o repositório switchyard-libs ==="

node -e '
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const manifest = JSON.parse(fs.readFileSync("manifest.json", "utf8"));

for (const [toolName, tool] of Object.entries(manifest.toolchains)) {
  console.log(`\n📦 Verificando ${toolName} (${tool.distribuicao} ${tool.versao})...`);
  for (const [platform, pkg] of Object.entries(tool.plataformas)) {
    const dest = path.join(process.cwd(), pkg.arquivo);
    const destDir = path.dirname(dest);
    if (!fs.existsSync(destDir)) {
      fs.mkdirSync(destDir, { recursive: true });
    }

    let exists = false;
    if (fs.existsSync(dest)) {
      try {
        const sum = execSync(`shasum -a 256 "${dest}"`).toString().split(" ")[0].trim();
        if (sum.toLowerCase() === pkg.sha256.toLowerCase()) {
          console.log(`  ✓ [OK] ${platform}: ${pkg.arquivo} (SHA-256 confere)`);
          exists = true;
        } else {
          console.log(`  ⚠ Checksum divergente para ${platform}. Baixando novamente...`);
        }
      } catch (err) {}
    }

    if (!exists) {
      console.log(`  ⬇ Baixando [${platform}] de ${pkg.urlOrigem} -> ${pkg.arquivo}...`);
      execSync(`curl -fSL -o "${dest}.tmp" "${pkg.urlOrigem}"`, { stdio: "inherit" });
      const sum = execSync(`shasum -a 256 "${dest}.tmp"`).toString().split(" ")[0].trim();
      if (sum.toLowerCase() !== pkg.sha256.toLowerCase()) {
        fs.unlinkSync(`${dest}.tmp`);
        throw new Error(`Checksum inválido para ${pkg.arquivo}. Esperado: ${pkg.sha256}, obtido: ${sum}`);
      }
      fs.renameSync(`${dest}.tmp`, dest);
      console.log(`  ✓ Concluído: ${pkg.arquivo}`);
    }
  }
}
'

echo -e "\n🎉 Todos os pacotes foram verificados com sucesso!"
