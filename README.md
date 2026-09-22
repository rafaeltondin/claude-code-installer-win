# Claude Code Installer (Windows)

Instalador `.bat` para configurar um Windows do zero com:

- [Chocolatey](https://chocolatey.org/) (gerenciador de pacotes)
- Node.js LTS
- Git
- LibreOffice (gratuito, sem ativação)
- [Claude Code](https://claude.com/claude-code) via instalador nativo oficial (`irm https://claude.ai/install.ps1 | iex`)

A pasta `dotclaude-clean/` traz uma configuração de exemplo GENÉRICA (sem nomes,
credenciais, automações de negócio ou dados pessoais) copiada para
`%USERPROFILE%\.claude` durante a instalação.

## Como usar

1. Baixe/clone este repositório no Windows.
2. Clique com o botão direito em `instalar.bat` → **Executar como administrador**.
3. Aguarde a instalação terminar.
4. Abra um novo terminal e rode `claude` para logar na sua conta Anthropic.

## O que NÃO está incluído (de propósito)

- Vault / segredos
- Scripts e automações pessoais/de negócio
- Base de conhecimento pessoal
- Qualquer dado identificável

## Aviso sobre Office

Este instalador usa **LibreOffice** (gratuito e legal). Não inclui, nem nunca vai
incluir, ativadores/cracks de Microsoft Office — isso é pirataria e não é
suportado neste projeto.
