---
title: "Vídeo Ads em Remotion — Pipeline (React + narração ElevenLabs sincronizada)"
category: "Marketing"
tags:
  - video-ads
  - remotion
  - react
  - elevenlabs
  - narração
  - legendas
  - reels
  - stories
  - tiktok
  - motion-design
  - motion
  - efeitos
  - fundo
  - meta-ads
  - ffmpeg
summary: "Pipeline para criar anúncios em vídeo 9:16 com Remotion (React): arquitetura modular, narração ElevenLabs sincronizada por cena, RevealText (texto surge palavra a palavra), showcase sequencial (1 item por vez + dots), fundo dedicado por cena + biblioteca de efeitos (bokeh/pulse-rings/aurora/twinkles/particles), logos oficiais de plataforma, design system (60-30-10, safe-area, mono, glass) e gotchas de render. 2 templates prontos: betpredict (produto) e riwerlabs (agência/serviços). Substitui o motion-ads HTML/GSAP descontinuado."
last_reviewed: "2026-08-22"
secrets_required:
  - ELEVENLABS_API_KEY
---

# Vídeo Ads em Remotion — Pipeline

Pipeline canônico para anúncios em **vídeo** (Reels/Stories/TikTok, 1080×1920 @30fps). Substitui o antigo *motion-ads toolkit* (HTML/GSAP/Puppeteer), descontinuado em 2026-06-09 por ser frágil (autoFit, captura por screenshot, sem áudio nativo). Remotion dá React declarativo, áudio/narração nativos, render determinístico e preview rápido.

> **Templates prontos** (sem `node_modules` — copiar, `npm i`, ajustar, renderizar):
> - `templates/remotion-video-ad-betpredict/` — **produto/SaaS**, 1 herói por cena, card de dados, gancho com trocadilho visual (bola no "O"). 9:16, ~45s.
> - `templates/remotion-video-ad-riwerlabs/` — **agência/serviços**, gancho de dores 1-por-vez, **showcase sequencial** de N serviços com dots de progresso, diferenciais/processo, **fundo dedicado por cena**. 9:16, ~50s.
> - `templates/remotion-video-ad-broll-narracao/` — **B-roll de banco (Pexels) + narração**: o herói é o **take de vídeo real** sincronizado à fala, com legenda palavra-a-palavra, chips de palavra-chave e **música ducked**. Para anúncios sem footage próprio (ex.: jurídico/serviços). 9:16, ~30s. Tem README com o fluxo (4 scripts) e os padrões abaixo. Caso real: OSPP Advogados (jun/2026).
> Casos reais: BetPredict, RiwerLabs e OSPP (jun/2026).

## ⭐ PADRÃO OBRIGATÓRIO (sempre seguir ao criar vídeo ad)
> Regras consolidadas a partir do feedback real do Rafael (jun/2026). **Seguir todas por padrão** — só desviar com pedido explícito. Validar cada item antes de declarar "pronto".

**Estrutura / layout**
- 9:16 **1080×1920 @30fps**; arco de 5 cenas: **gancho (dor) → solução/serviços → diferenciais → processo → CTA**.
- Espaçamento **Fibonacci** (tokens `fib.*`); margem-mestre; **safe-area** (conteúdo fora de ~210px topo / ~260px base).
- **60-30-10**: fundo escuro 60, branco/cinza 30, **1 acento 10** (acento só no dado-herói + CTA).
- **Fundo DEDICADO por cena** (nunca o mesmo em todas) — `SceneBackground` por `SceneId`, mood próprio por cena.
- Marca contínua: **logo bug** no topo + **barra de progresso**; **crossfade** entre cenas.
- Glassmorphism (borda viva + specular) quando houver card.

**Fontes / tipografia**
- `loadFont()` SEMPRE chamado (senão cai em fallback). **Letras GROSSAS** — pesos altos (600–900), **heróis em 900**.
- **Números em mono** (JetBrains) com `tabular-nums`.
- **Tudo em maiúsculas** (textTransform uppercase global; logo é imagem, não afetado).
- **Máx. ~5 palavras grandes por take** — o resto vira ícone/badge/card (texto pequeno).

**Fala / narração**
- ElevenLabs voz **Will** (`IKpiSijWzlhOL6uX83EH`). Roteiro pt-BR punchy, **CTA no fim**, cobrindo o texto da tela.
- **Sincronia exata exige `/with-timestamps`** (alinhamento por palavra). ⚠️ `eleven_v3` NÃO suporta timestamps → usar **`eleven_multilingual_v2`** (mesma voz). Salvar `narration-timing.json`.

**Tempos / exibição (o ponto mais sensível)**
- Timeline **derivada das durações reais** (ffprobe) por cena: `cena = head + VO + tail`.
- **Texto aparece no INSTANTE EXATO da fala** — ancorar cada elemento ao timestamp real da palavra (`lib/narration.ts → wordFrame/anchorFrame`), **nunca por estimativa**.
- **Texto surge palavra a palavra** (`RevealText`) conforme falado.
- Lista com muitos itens (ex.: serviços) = **UM POR VEZ** (ícone grande + nome), cada um no frame em que é citado + **dots de progresso**. NUNCA grid/parede de texto.
- Animações internas **espalhadas ao longo da fala** (não tudo no 1º segundo).
- **Ícones oficiais de plataforma** (Meta/Google Ads) por uso nominativo (SVG via `<Img>`).

**Anti-padrões (REJEITADOS pelo Rafael — não usar)**
- ❌ Brackets de canto (cara de "foco de câmera"). ❌ Mesmo fundo em todas as cenas. ❌ **Linhas varrendo** — nem lado-a-lado (scan horizontal) nem descendo (scan-wipe / scanlines deslizantes). Usar efeitos **orgânicos**: bokeh, pulse-rings, aurora, twinkles, partículas, glows.

**Pipeline / validação**
- Validar design com **`remotion still`** (1 frame) ANTES do render cheio (~1h).
- Render **`--concurrency=4`** (6 piora — contenção de CPU). Evitar `filter:blur` full-screen e `feTurbulence` pesado.
- Conferir: `ffprobe` (tem áudio + duração), `ffmpeg -af volumedetect` (não silêncio, mirar ~ -20 dB), frames-chave. **Bumpar versão**.

## Variante B-roll de banco + narração (template `-broll-narracao`)
Quando NÃO há footage próprio: imagem = takes da Pexels casados ao que é narrado.
Preferências FIXAS do Rafael (jun/2026 — sempre, só desviar com pedido):
- **Legenda a 35% da altura a partir do fundo** (`layout.captionBottom = round(height*0.35)`), não colada na base.
- **Palavra-chave (chips) SEM botão/pílula** atrás — só o texto, com sombra/halo, **centralizado no MEIO da tela** (vertical+horizontal). Nada de retângulo/fundo na palavra.
- **Legenda KARAOKÊ amarela** (ref. `IMG_2682_legendado.mp4`): palavra falada = **amarelo `#F6DC11`**, resto **branco**, **contorno preto** (`WebkitTextStroke ~5px` + `paintOrder:"stroke fill"`), bold. Mesma família do título.
- **Fonte:** Rafael pediu **Poppins em tudo** (sobrepôs fontes da identidade); default = Poppins. **Cores** ainda da IDENTIDADE do cliente — extrair do site (via `firefox-bridge`: `firefox_eval` pra ler cores dominantes/`--vars` computados do CSS; bridge atual, aposentou o chrome-bridge em 2026-08-22 — ver `FIREFOX-BRIDGE-BIDI.md`). Ex. OSPP: navy `#1C2745`/`#111B37`, dourado `#CC9231`. Título no navy `#111B37` + **halo claro** p/ ler sobre B-roll.
- **Música de banco royalty-free** (ex.: Kevin MacLeod/incompetech CC-BY — guardar atribuição) **abaixo da voz** (~0.16/−16 dB) + **master `loudnorm I=-14`** (social).
- Voz Will + `eleven_multilingual_v2` (timestamps); B-roll Pexels `orientation=portrait`; CTA com WhatsApp + selo OAB quando jurídico.
- **Render rápido sem perda:** pré-transcodar B-roll p/ **1080×1920 30fps CFR CRF18** (casa a comp) + `--concurrency=<nº cores>` + `--image-format=jpeg`. (clipes de banco vêm em 25fps → seek a cada frame; casar fps acelera muito.)

## Quando usar
- Anúncio com **movimento/narração/dados animados** (contador, barras, scanner).
- Estáticos/carrossel/imagem de produto → continuam em `META-ADS-CRIATIVOS.md`.
- Copy/roteiro/narração → `COPY-PERSUASAO-STORYTELLING-ANUNCIOS.md` + `NARRACAO-ANUNCIOS-PLAYBOOK.md`.

## Stack
- **Remotion 4** (`@remotion/cli`, `remotion`), React 18, TypeScript.
- **Fontes:** `@remotion/google-fonts/Montserrat` (texto) + `@remotion/google-fonts/JetBrainsMono` (números).
- **Narração:** ElevenLabs (voz padrão **Will** `IKpiSijWzlhOL6uX83EH`, modelo `eleven_v3`) — ver `ELEVENLABS-API.md`.
- **Render/validação:** chromium do Remotion + `ffmpeg`/`ffprobe`.

## Arquitetura modular (src/)
```
theme.ts            tokens: paleta, Fibonacci, tipografia, layout/safe-area, carrega as fontes
lib/   random.ts    PRNG determinístico (NUNCA Math.random no render)
       math.ts      clamp/lerp/remap/easings
       hooks.ts     useEnter/useFade/useCounter/useGrow/usePulse (spring/interpolate)
       timeline.ts  FONTE ÚNICA do tempo: VO_SECONDS por cena -> from/duração/voOffset; CAPTION
components/          NeuralNet, Background, Grain(+vinheta), GlassCard, Crest, ScanLine,
                    ProbabilityBar, ConfidenceBar, AnimatedNumber, TagPill, Logo, LogoBug,
                    Sparks, SceneWrapper(crossfade + scan-wipe), Captions, ProgressBar, SafeArea,
                    HeroGlow, SoccerBall(bola SVG), PitchLines(gramado) — situam "futebol" no gancho
scenes/             HookScene, ScannerScene, FeaturesScene, HonestyScene, CtaScene
BetPredictAd.tsx    orquestra: Background -> cenas(Sequence) -> Narration -> Grain -> ProgressBar -> LogoBug
Root.tsx            registra composição (duração = TOTAL_FRAMES da timeline)
```

## Narração sincronizada (o pulo do gato)
1. **Gerar por cena** (1 mp3/cena) com script `gen-narration.mjs` (timeout 30s + retry/backoff + fallback de modelo + throttle). Rodar via vault:
   `node ~/.claude/vault/vault-cli.js run --names=ELEVENLABS_API_KEY -- node gen-narration.mjs <OUT_DIR>`
2. **Medir a duração real** de cada clipe: `ffprobe -v error -show_entries format=duration -of csv=p=0 x.mp3`.
3. **Timeline deriva tudo** dessas durações (`VO_SECONDS` em `lib/timeline.ts`): `cena = head + voDuration + tail`. Mudou a narração → muda só `VO_SECONDS` e a composição inteira se reajusta.
4. Cada `<Audio>` entra em `scene.from + voOffset` (componente `Narration`).
5. **Animações internas espalhadas pelas falas** (não tudo no 1º segundo): contador conta quando a voz cita o número, barra de probabilidade anima em "casa/empate/fora", etc. Sem isso a cena longa "congela".
6. **Legendas queimadas** (`Captions`): ~80% assiste sem som. Sem timestamps por palavra do TTS, distribui o tempo entre palavras **ponderado pelo comprimento** dentro da janela da fala; palavra ativa em destaque. Pôr legenda só onde a fala vai além do texto-herói (não duplicar título gigante).

## Design system (o que separa "template" de peça profissional)
- **Espaçamento Fibonacci** (regra global) — tokens `fib.*`.
- **60-30-10:** fundo/escuro 60, branco/cinza 30, **1 acento (verde) 10** — verde só no dado-herói + CTA, senão "tudo verde = nada destaca".
- **Contraste:** texto secundário `#CBD5E1` (não `#94A3B8`); vinheta leve (`200px 60px`, não `320px`).
- **Safe-area Reels:** conteúdo fora de ~210px topo / ~320px base (UI das plataformas) — `SafeArea`.
- **Números em mono** (JetBrains) com `tabular-nums` — look "dados/IA".
- **Glassmorphism** com borda viva + specular highlight (`GlassCard`).
- **Marca contínua:** `LogoBug` no topo + `ProgressBar` (retenção).
- **Transição-assinatura:** scan-wipe verde na entrada de cada cena (`SceneWrapper`).
- **Cor com significado:** wash vermelho (caos) no gancho → verde (dados) no resto.

## Padrões de motion (aprendidos no caso RiwerLabs)
Feedback real do cliente virou regra — aplicar quando o conteúdo for "muitos itens" ou texto denso:
- **1 coisa por vez (showcase sequencial):** quando há N itens (12 serviços), NÃO empilhar grid/lista — mostrar **um por vez** (ícone grande + nome curto), cada um entrando em sincronia com a fala, com **dots de progresso** indicando o total. Muito mais limpo que grid. Mesmo padrão das "dores" do gancho.
- **Máx. ~5 palavras grandes por take.** Texto grande = poucas palavras; o resto vira **ícone/badge/card** (texto pequeno). Parede de texto = "feio/simples".
- **Texto surge conforme a fala** (`RevealText`): revelar **palavra a palavra** (fade + leve subida, escalonado por `perWord`), sincronizado com a janela de narração da cena. Aceita segmentos com cor (acentos). Aplicar no herói de TODAS as cenas.
- **Fundo DEDICADO por cena** (`SceneBackground` despacha por `SceneId`): cada take tem o seu — "fundo igual em todo lugar" é a reclamação nº1. Cada bg roda só na sua cena (custo por frame **não acumula**; remove o `Background` global).
- **Logos oficiais de plataforma** (Meta/Google Ads) por uso nominativo: baixar SVG (simpleicons / vectorlogo.zone) e renderizar via `<Img staticFile>` — `ServiceIcon` detecta a chave e ignora o tint de categoria. (ImageMagick não rasteriza SVG com `clipPath`; o Chromium do Remotion sim.)
- **Evitar "linhas que passam":** o usuário rejeitou tanto a **varredura horizontal** (linha cruzando lado a lado) quanto a **linha descendo** (scan-wipe de transição e scanlines deslizantes). Preferir movimento **orgânico** (aurora, bokeh, pulse-rings, twinkles) a linhas duras varrendo.

## Biblioteca de efeitos de fundo (`components/bg/`)
Primitivas baratas (div/SVG, sem `filter:blur` full-screen) compostas em `SceneBackground`:
`ParticleField` (brasas/faíscas/confete), `Bokeh` (orbs desfocados), `PulseRings` (radar/sonar), `Aurora` (bandas diagonais suaves), `Twinkles` (estrelas cintilando), `DotGrid` (grade pulsante), `FloatingShapes` (polígonos), `LightStreaks` (rastros verticais), `Rays` (sunburst girando), `Scanlines`/`Glitch`, `BlueprintGrid` (grade técnica), `Glow` (radial). `lib/particles.ts` = geradores determinísticos. Mood por cena: gancho=alarme(vermelho), serviços=energia(lima), diferenciais=técnico(azul), processo=fluxo(roxo), cta=celebração(lima).

## Render e validação
- **Preview barato primeiro:** `npx remotion still src/index.ts <Comp> out.png --frame=N` (1 frame, segundos) — validar design ANTES do render cheio (que é longo).
- **Render:** `npx remotion render src/index.ts BetPredictAd out/video.mp4 --concurrency=4`.
- **Validar de verdade:** `ffprobe` (tem stream de áudio? duração?) + `ffmpeg -af volumedetect` (não é silêncio? mean ~ -20dB) + extrair frames-chave e inspecionar.
- Entregar copiando p/ destino (ex.: `/mnt/c/Users/<user>/Desktop/`).

## Gotchas (aprendidos no caso BetPredict)
- **`loadFont()` é obrigatório.** Só pôr `fontFamily: "Montserrat"` como string NÃO carrega a fonte — o Chromium cai em fallback silencioso. Chamar `loadFont()` (em `theme.ts`) e usar a família retornada.
- **Emoji não renderiza** no chromium headless do Remotion (sem fonte de emoji → caixa vazia/"tofu"). Desenhar ícones em **SVG**.
- **`Math.random()`/`Date.now()`** quebram reprodutibilidade entre workers de render — usar PRNG determinístico (`lib/random.ts`).
- **Grão SVG (`feTurbulence`) por frame encarece o render** (~2-3x). Aceitável, mas é o maior custo; se precisar de velocidade, baixar intensidade/numOctaves ou pré-renderizar.
- **`filter: blur()` full-screen por frame é caríssimo** (dobrou o render no mesh). Usar gradiente radial suave (falloff `transparent 65%`) em vez de blur.
- **Concorrência: mais workers ≠ mais rápido** em WSL/CPU limitada. `--concurrency=6` ficou PIOR que `4` (contenção de CPU no SVG pesado, não memória). `4` é o ponto ótimo aqui (8 cores lógicos).
- **Fundo por cena é mais barato que global:** cada bg roda só na sua `Sequence` → custo por frame não soma os 5. Preferir a global persistente.
- **Stills antes do render cheio:** `npx remotion still ... --frame=N` valida design em segundos; render completo (~50s/1499 frames) leva ~1h. Validar SEMPRE por still antes.
- **Logo da marca:** baixar do site (`/img/logo.png` costuma ter alpha) e checar sobre fundo escuro antes; logo é imagem, não sofre `text-transform`.
- **Trademark:** logos de clube/liga (ex.: api-sports) são marca registrada — em anúncio de apostas implicam endosso. Usar **escudos custom**, não logos reais, salvo direitos.
- **Reprodução pausando sozinha** no PC de quem assiste ≠ problema do arquivo: em notebooks com **Modern Standby (S0)**, a tela apagando entra em standby conectado e **pausa a mídia**. Fix no Windows: `powercfg /change monitor-timeout-ac 0`. (Fone Bluetooth com HFP/AVRCP também pausa mídia via comando fantasma.)

## Cheat-sheet
```bash
# 1. narração
node ~/.claude/vault/vault-cli.js run --names=ELEVENLABS_API_KEY -- node gen-narration.mjs ./narration
for f in narration/*.mp3; do ffprobe -v error -show_entries format=duration -of csv=p=0 "$f"; done
# 2. atualizar VO_SECONDS em src/lib/timeline.ts com as durações
# 3. preview rápido
npx remotion still src/index.ts BetPredictAd preview.png --frame=400
# 4. render + validar
npx remotion render src/index.ts BetPredictAd out/video.mp4 --concurrency=4
ffprobe -v error -show_entries format=duration:stream=codec_type -of csv=p=0 out/video.mp4
ffmpeg -hide_banner -i out/video.mp4 -af volumedetect -f null /dev/null 2>&1 | grep volume
```

## Variantes de fundo (2026-09)

O fundo do anúncio não precisa ser só B-roll de banco (Pexels). Variantes usadas e validadas (sessão Barefoot Fiber, 18/09/2026), todas trocando só o componente `Broll` do template:
- **Imagem do site com movimento:** usar fotos do produto (Shopify) como fundo, com Ken Burns (zoom+pan) nas de ambiente e "produto centralizado sobre fundo desfocado" nas de catálogo (fit contain). `Img` no lugar de `OffthreadVideo`.
- **Foto de produto em fundo CLARO → fundo escuro cinematográfico:** recortar o fundo liso (ex.: `#DCDCDC`) com ImageMagick 6 `convert foto.webp -fuzz 16% -transparent "#DCDCDC" cut.png` e compor sobre `radial-gradient` escuro (`convert -size 1080x1920 radial-gradient:"#2a2a2a"-"#060606" bg.png` + composite). Evita legenda branca ilegível sobre fundo claro. Só funciona bem com produto escuro (recorte não come detalhe claro).
- **Take de IA (OpenRouter) p/ cenas conceituais:** cenas que não dá pra filmar (metáforas, "tênis comum", instabilidade) geradas via OpenRouter vídeo — ver [[OPENROUTER-VIDEO-GERACAO]]. Regra prática do Rafael: cenas do PRODUTO = filmagem real; cenas conceituais = IA, no mesmo clima visual. Normalizar o clipe de IA (24→30fps CFR 1080x1920) antes de entrar no Remotion.
- **Sem link no topo (PADRÃO desde 2026-09-29):** nunca colocar o link do site no vídeo — remover `<BrandMark/>`. E sem sobreposição escura (`<Scrim/>`/vinheta) por cima do take — ver VIDEO-ADS-PADRAO-AD01-CINEMATOGRAFICO.md.
