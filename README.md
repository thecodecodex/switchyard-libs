# Switchyard Libs & Toolchains (`@thecodecodex/switchyard-libs`)

Repositório público oficial de pacotes compactados, toolchains e bibliotecas padronizadas para o ecossistema [Switchyard](https://switchyard.thecodecodex.com).

---

## 🎯 Objetivo

Centralizar os binários e distribuições oficiais utilizadas pelo CLI `syd` e pelos ambientes de desenvolvimento em uma estrutura versionada e imutável via **Git LFS**, garantindo que qualquer desenvolvedor ou pipeline tenha acesso idêntico e auditável às ferramentas:

- **JDK 17** (Eclipse Temurin LTS)
- **JDK 25** (Eclipse Temurin)
- **Node.js 22** (LTS)
- **Go 1.27**

---

## 📂 Estrutura de Diretórios

```text
switchyard-libs/
├── manifest.json              # Manifesto central com versões, caminhos locais, SHA-256 e URLs
├── .gitattributes             # Rastreamento Git LFS (*.tar.gz, *.zip)
├── scripts/
│   ├── download.sh            # Script para download dos pacotes das fontes oficiais
│   └── verify.sh              # Validador de integridade e checksums SHA-256
├── java/
│   ├── jdk-17/                # Eclipse Temurin 17.0.20.1+1
│   │   ├── darwin-arm64.tar.gz
│   │   ├── darwin-amd64.tar.gz
│   │   ├── windows-amd64.zip
│   │   └── linux-amd64.tar.gz
│   └── jdk-25/                # Eclipse Temurin 25.0.4.1+1
│       ├── darwin-arm64.tar.gz
│       ├── darwin-amd64.tar.gz
│       ├── windows-amd64.zip
│       └── linux-amd64.tar.gz
├── node/
│   └── node-22/               # Node.js 22.23.3
│       ├── darwin-arm64.tar.gz
│       ├── darwin-amd64.tar.gz
│       ├── windows-amd64.zip
│       └── linux-amd64.tar.gz
└── go/
    └── go-1.27/               # Go 1.27.1
        ├── darwin-arm64.tar.gz
        ├── darwin-amd64.tar.gz
        ├── windows-amd64.zip
        └── linux-amd64.tar.gz
```

---

## 🚀 Como o Switchyard consome este repositório

Quando o comando `syd setup toolchains` ou `syd setup all` é acionado:

1. O Switchyard garante o clone do repositório em `~/.switchyard/libs`:
   ```bash
   git clone --filter=blob:none https://github.com/thecodecodex/switchyard-libs.git ~/.switchyard/libs
   ```
2. Baixa via Git LFS apenas os pacotes correspondentes à plataforma local (`darwin-arm64`, `linux-amd64`, etc.):
   ```bash
   git lfs pull --include "<tecnologia>/<versao>/<plataforma>.*"
   ```
3. Valida a integridade via hash SHA-256 definido em `manifest.json`.
4. Extrai em `~/.switchyard/toolchains/<nome>` e configura automaticamente variáveis de ambiente (`JAVA_HOME`, `PATH`, etc.).

---

## 🛠️ Scripts de Manutenção

### Baixar pacotes oficiais para o repositório
```bash
./scripts/download.sh
```

### Validar integridade dos pacotes locais contra o manifesto
```bash
./scripts/verify.sh
```
