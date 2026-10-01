---
name: criar-video-banco-video
description: Cria um anúncio vertical 9:16 (Reels/Stories/TikTok) usando o método "B-roll de banco + narração" — quando NÃO há filmagem própria, busca vídeos/imagens no Pexels (banco gratuito) e usa cada trecho como FUNDO sincronizado ao que está sendo narrado, com narração IA (ElevenLabs/Will), legenda no PADRÃO AD01 (Montserrat Black, maiúsculas, blocos de 2–4 palavras centralizados, sem escurecer o vídeo e sem link do site) e trilha crescente. Parte do template aprovado remotion-video-ad-broll-narracao. Use quando o Rafael pedir "cria um vídeo com vídeos de banco", "monta um anúncio com b-roll do Pexels", "vídeo de fundo de banco de imagem com narração", ou invocar /criar-video-banco-video.
---

# PAPEL

Você monta um anúncio vertical de venda (9:16, 1080×1920, 30fps) para quem NÃO tem filmagem própria. O "herói" da imagem é o **B-roll de banco gratuito** (vídeos do Pexels) usado como FUNDO, com cada trecho casado ao que está sendo narrado naquele instante. Por cima entram: narração IA e legenda no PADRÃO AD01 (Montserrat Black maiúscula, blocos de 2–4 palavras centralizados no meio), com fundo cinematográfico escuro e trilha que cresce.

Pense em você como um editor de anúncio: recebe um roteiro (o texto que vai ser narrado), transforma esse texto em voz, escolhe um vídeo de banco pra cada frase, encaixa tudo no tempo certo e entrega o MP4 pronto pra postar.

Este é um pipeline determinístico baseado no template APROVADO pelo Rafael (`remotion-video-ad-broll-narracao`, referência OSPP roteiro 07). NÃO reinventar o visual — copiar o template e trocar só o conteúdo (roteiro, buscas de vídeo, chips, CTA, cores da marca).

# CONTEXTO / KB OBRIGATÓRIA

Antes de começar, ler e seguir estes documentos da base de conhecimento (são a fonte da verdade deste método):
- `~/.claude/knowledge-base/VIDEO-ADS-PADRAO-AD01-CINEMATOGRAFICO.md` — PADRÃO VISUAL DEFAULT (legenda, fonte, fundo, transições, áudio). LER PRIMEIRO.
- `~/.claude/knowledge-base/VIDEO-ADS-REMOTION-PIPELINE.md` — pipeline geral e regras de fundo.
- `~/.claude/knowledge-base/templates/remotion-video-ad-broll-narracao/README.md` — o passo-a-passo canônico (formato fixo, 4 scripts, render, gotchas). LER INTEIRO.
- `~/.claude/knowledge-base/NARRACAO-ANUNCIOS-PLAYBOOK.md` — regras de narração.
- `~/.claude/knowledge-base/ELEVENLABS-API.md` — geração de voz + timestamps.
- `~/.claude/knowledge-base/COPY-PERSUASAO-STORYTELLING-ANUNCIOS.md` — se for preciso escrever/ajustar o roteiro.

Como o trabalho é frontend/visual, também valem os docs de design (regra §14 do CLAUDE.md): tokens, escala Fibonacci, identidade visual da marca.

# PRÉ-REQUISITOS (checar ANTES de rodar)

1. **Chave do banco de vídeos Pexels** — `node ~/.claude/vault/vault-cli.js has PEXELS_API_KEY`. Se AUSENTE: avisar o Rafael em linguagem leiga que precisa da chave gratuita do Pexels (pega em pexels.com/api, é grátis) e guardar com `VAULT_VALUE="a-chave" node ~/.claude/vault/vault-cli.js set PEXELS_API_KEY`. Sem ela o passo de baixar os vídeos de fundo NÃO roda.
2. **Chave da voz ElevenLabs** — `node ~/.claude/vault/vault-cli.js has ELEVENLABS_API_KEY` (já costuma existir).
3. **Ferramentas** — node, npx e ffmpeg no PATH (já instalados no host).

Se faltar uma chave, PARAR e pedir ao Rafael antes de seguir — não inventar.

# ENTRADA (o que o Rafael fornece)

- O **roteiro** (o texto que vai ser narrado), ou o tema/produto pra você escrever o roteiro (aí passar pelo copy-reviewer antes).
- A **marca/cliente** (pra extrair cores da identidade e montar o CTA). Se jurídico, aplicar regras OAB (sem promessa de resultado/urgência).
- Dados do **CTA**: WhatsApp/site, selo quando houver.

Se o pedido estiver vago (sem roteiro, sem marca, sem CTA), fazer o formulário de contexto (AskUserQuestion) antes de executar — regra §3 do CLAUDE.md.

# FLUXO (executar em ordem, validando cada passo)

Trabalhar SEMPRE dentro do `$SESSION_DIR` (nunca editar o template original in-place).

## 1. Preparar o projeto
```bash
cp -r ~/.claude/knowledge-base/templates/remotion-video-ad-broll-narracao "$SESSION_DIR/video-broll"
cd "$SESSION_DIR/video-broll" && npm install
```

## 2. Narração (voz + timestamps por palavra)
Editar `LINES` em `gen-narration.mjs` (id + texto de cada roteiro). Voz Will (`IKpiSijWzlhOL6uX83EH`), `eleven_multilingual_v2`, tom sério/pausado.
```bash
node ~/.claude/vault/vault-cli.js run --names=ELEVENLABS_API_KEY -- node gen-narration.mjs
```
Gera `public/narration/<id>.mp3` + `data/narration-timing.json` (palavra→tempo, duração). Anotar a duração real: ela define o tamanho do vídeo.

## 3. B-roll de banco (o FUNDO — coração deste método)
Editar `SHOTS` em `fetch-broll.mjs`: um "beat" por frase/ideia, com janela `[start,end]` em segundos DERIVADA dos timestamps reais da narração (passo 2), e uma `query` em INGLÊS descrevendo a imagem que combina com aquela fala. `orientation=portrait` (o script já força retrato ~1080). Cada beat cobre uma janela curta (3–7s), porque o clipe de banco é quase sempre plano-único.
```bash
node ~/.claude/vault/vault-cli.js run --names=PEXELS_API_KEY -- node fetch-broll.mjs
```
Gera `public/broll/<id>/clip_NN.mp4` + `data/shotlist.json`. Conferir no `data/broll.log` que TODOS os beats baixaram (silêncio não é sucesso — o log tem que mostrar cada clipe com resolução e tamanho).

## 4. Música (royalty-free, abaixo da voz)
Baixar uma faixa royalty-free pra `public/music/` (ex.: incompetech.com, Kevin MacLeod CC-BY). Guardar atribuição em `public/music/LICENSE.txt`. A voz SEMPRE fica acima: música ducked a `musicVolume ≈ 0.16` (~−16 dB).

## 5. Baked dos dados + config
```bash
node build-data.mjs      # escreve src/adData.ts (duração, words[], shots[])
```
Ajustar em `src/adConfig.ts`: chips (t/dur/texto da palavra-chave), `ctaStartSec`, música+volume, e o `CTA` (marca/WhatsApp/selo). Cores da IDENTIDADE do cliente em `src/theme.ts` (extrair do site oficial via firefox-bridge quando possível, nunca genérico). Legenda no PADRÃO AD01 (ver seção FORMATO FIXO): Montserrat Black maiúscula, branca sem contorno, blocos de 2–4 palavras centralizados; deixar `chips: []`.

## 6. Validar por still ANTES do render cheio
```bash
npx remotion still src/index.ts <CompId> out/chk.png --frame=270
```
Abrir o PNG com a ferramenta Read e conferir de verdade: fundo certo, legenda legível, chip no lugar, cores da marca. Re-ajustar até ficar bom.

## 7. Render (rodar em BACKGROUND — passa de 30s)
Pré-transcodar o B-roll pra 1080×1920 30fps CFR CRF18 acelera MUITO (o gargalo é o decode do vídeo de banco). Depois:
```bash
# via lançador padrão de background (regra §9), com watcher no mesmo turno
~/.claude/scripts/bg-run.sh render-video -- npx remotion render src/index.ts <CompId> out/final.mp4 --concurrency=4 --image-format=jpeg
```
Acompanhar o log com Monitor filtrando `ERROR|Error|rc=[1-9]|done|\[DONE\]`.

## 8. Master de loudness (entrega social)
```bash
ffmpeg -i out/final.mp4 -af loudnorm=I=-14:TP=-1:LRA=11 -c:v copy -c:a aac -b:a 192k "$SESSION_DIR/entrega.mp4"
```

## 9. Validar e entregar
Assistir/conferir frames-chave do resultado (regra §4 e §14 — validar com os próprios olhos). Só então reportar pronto. Mandar o arquivo pro Rafael com SendUserFile.

# FORMATO FIXO — PADRÃO AD01 (default aprovado; detalhe em VIDEO-ADS-PADRAO-AD01-CINEMATOGRAFICO.md)
- **Legenda:** blocos de **2–4 palavras**, **MAIÚSCULAS**, **Montserrat Black**, **branca sem contorno**,
  **cada palavra surge no instante em que é narrada** (pop), fonte grande (~92px), **centralizada no meio** da tela. **Palavras FORTES em VERMELHO** (`palette.red`), resto branco — lista em `emphasisWords` no `adConfig.ts`. NÃO usar karaokê amarelo (padrão OSPP antigo, aposentado).
- **Topo:** LIMPO — **SEM link do site** nem marca (regra do Rafael 2026-09-29). O template já não renderiza `<BrandMark/>`.
- **Legenda NUNCA pode estourar a tela:** a fonte encolhe sozinha pela palavra mais longa do bloco (auto-fit `fitSize`), `maxWidth 90%` + `flex-wrap`. SEMPRE validar por still a cena da palavra mais longa antes do render. Texto cortado = falha de entrega.
- **Fundo:** o take com as **cores originais** — **SEM sobreposição escura** (sem scrim/vinheta/escurecer; regra do Rafael 2026-09-29). Legibilidade só pela sombra desfocada da letra. O template já não renderiza `<Scrim/>`.
  **Fundo DEDICADO por cena** — nunca o mesmo B-roll em todas.
- **Paleta:** preto + branco + bege/dourado `#C6A06B` (default). Cores da marca do cliente quando houver identidade clara.
- **Takes curtos (2–5s)**, corte seco + um flash rápido na virada.
- **Efeitos sonoros por palavra (SFX):** pontuar palavras-chave com efeito no instante narrado (mapa `sfx-map.json`; ex.: whatsapp→notify, pedido→chaching, cupom→coin, link→pop). Usar equivalentes sintetizados/royalty-free, NUNCA o som oficial de marca (copyright). Voz sempre acima; volume embutido no .wav; mixar com `amix normalize=0` + `loudnorm I=-14`; helper `build-sfx-cmd.mjs`. Detalhe na KB (VIDEO-ADS-PADRAO-AD01, seção 7.1).
- **Áudio:** trilha que **CRESCE** ao longo do vídeo (não constante); SEM whoosh na transição de take (só efeitos por palavra).
  Voz sempre acima da música + master `loudnorm I=-14`.
- **Sem grão de filme** (feTurbulence desligado — maior custo de render).
- Voz **Will**, `eleven_multilingual_v2`, tom sério/pausado.
- **SEM card/box animado em código no fim** (o Rafael NÃO quer). O fim é a última fala como legenda palavra-a-palavra + **seta dupla piscando** (`EndChevron`). Remover `<CtaCard>` do `OsppAd.tsx`.
  Se jurídico, regras OAB (sem promessa de resultado/urgência/número).

# GOTCHAS
- ffmpeg scene detect: a constante é `scene` (singular), não `scenes`.
- Emoji não renderiza no chromium do Remotion (vira tofu) — usar SVG.
- `feTurbulence`/blur full-screen por frame explode o tempo de render — manter desligado.
- `Math.random()`/`Date.now()` quebram reprodutibilidade entre workers — usar PRNG/props.
- Pexels é quase sempre plano-único: cobrir janelas curtas (3–7s) por beat.
- Pré-transcodar o B-roll pra spec da comp (30fps CFR) é o maior ganho de velocidade lossless.

# DEFINIÇÃO DE PRONTO
MP4 9:16 renderizado, com áudio normalizado, legenda karaokê sincronizada, fundo de banco casando com a narração, CTA no fim — CONFERIDO visualmente frame a frame e entregue ao Rafael. Nunca declarar pronto sem assistir o resultado.
