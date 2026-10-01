# Claude Code Installer (Windows)

Instalador de um comando para deixar um Windows zerado pronto para rodar o
**Claude Code**, ja com uma configuracao padrao (regras de trabalho, base de
conhecimento de design/video/imagem, skills e agentes).

## Instalar (um comando)

Abra o **PowerShell normal** (NAO como administrador) e cole:

```powershell
$d="$env:USERPROFILE\Downloads"; $z="$d\claude-installer.zip"; [Net.ServicePointManager]::SecurityProtocol=3072; Invoke-WebRequest -UseBasicParsing 'https://codeload.github.com/rafaeltondin/claude-code-installer-win/zip/refs/heads/master' -OutFile $z; Expand-Archive $z $d -Force; Start-Process "$d\claude-code-installer-win-master\instalar.bat" -Wait
```

O proprio instalador pede a permissao de administrador apenas na parte que
precisa (Chocolatey, Node.js e Git). O Claude Code e instalado no SEU usuario.

Depois que terminar: **feche o terminal, abra um novo e rode `claude`**. Na
primeira vez ele pede o login na conta Anthropic.

## O que ele faz

1. Chocolatey (gerenciador de pacotes) — em janela de administrador
2. Node.js LTS e Git — em janela de administrador
3. Claude Code pelo instalador oficial da Anthropic (`irm https://claude.ai/install.ps1 | iex`)
4. Adiciona o Claude ao PATH do seu usuario, de forma permanente
5. Copia a configuracao de `dotclaude-clean/` para `%USERPROFILE%\.claude`
6. Testa de verdade (`claude --version`) antes de dizer que terminou

## Configuracao que vem junto (`dotclaude-clean/`)

- `CLAUDE.md` — regras globais de trabalho (invioláveis, fluxo, codigo, engenharia defensiva, design)
- `settings.json` — permissoes basicas
- `knowledge-base/` — guias de CSS/layout (sistema Fibonacci, tokens, @layer), landing page,
  psicologia das cores, efeitos de frontend, secoes e banners de loja Shopify,
  video ads (padrao cinematografico, pipeline Remotion, edicao em ffmpeg, narracao),
  imagem (manipulacao e prompts de geracao) e um exemplo real de identidade de marca
- `skills/` — design de frontend, boas praticas de Remotion, criacao de video com b-roll,
  geracao de imagem e diagrama de arquitetura
- `agents/` — especialistas de CSS, landing page, React/Vite, video, UX, acessibilidade,
  responsividade, copy, imagem, ffmpeg, narracao, SEO, testes de frontend e base de conhecimento

## O que NAO esta incluido (de proposito)

- Cofre de segredos, tokens e senhas
- Scripts e automacoes pessoais/de negocio
- Dados identificaveis de pessoas ou clientes
- Microsoft Office e, obviamente, nenhum ativador/crack

## Se o comando `claude` nao for reconhecido

1. Feche e abra um terminal novo (o PATH so vale em terminal novo).
2. Se ainda nao funcionar, reinicie o computador uma vez.
3. Conferir onde ele esta: `where.exe claude` e `dir "$env:USERPROFILE\.local\bin"`.
4. Forcar no PATH do usuario:
   `[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ";$env:USERPROFILE\.local\bin", 'User')`

Causa mais comum (corrigida nesta versao): rodar o instalador como
**administrador**. Nesse caso o Claude Code era instalado no perfil do
administrador e o seu usuario nunca via o comando.
