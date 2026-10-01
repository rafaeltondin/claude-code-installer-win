---
title: "Vídeo Ads — Padrão Visual AD01 (cinematográfico, legenda Montserrat Black, referência aprovada Rafael)"
category: "Marketing"
tags:
  - video-ads
  - legenda
  - caption
  - montserrat
  - reels
  - broll
  - cinematografico
  - ad01
  - transicao
  - whoosh
  - trilha crescente
  - padrao-rafael
topic: "Edição de vídeo / Anúncios"
priority: high
version: "1.1.0"
last_updated: "2026-09-29"
secrets_required: []
summary: "Padrão visual/sonoro APROVADO pelo Rafael para anúncios verticais, extraído do vídeo de referência AD01.mp4 (analisado em 2026-09-04). Define palavras por take, fonte/tamanho/cor da legenda, como as letras aparecem, layout, transições de take e áudio (trilha que cresce + whoosh nas transições). É o padrão DEFAULT de legenda da skill criar-video-banco-video, substituindo o karaokê amarelo do template OSPP."
---

# Padrão Visual AD01 (cinematográfico)

Padrão de referência aprovado pelo Rafael, extraído do anúncio `AD01.mp4`
(1080×1920, 30fps, ~68s, marca "maná alianças", nicho ótica/emocional).
Analisado quadro a quadro + áudio em 2026-09-04. Este é o **default de legenda**
para anúncios verticais — **substitui o karaokê amarelo** do template OSPP antigo.

## 1. Palavras por take / legenda
- **2 a 4 palavras por bloco**, geralmente em **duas linhas centralizadas** (ex.:
  "E NUNCA MAIS / CONSEGUIU VOLTAR", "TOQUE EM / SAIBA MAIS", "PARAR DE TRATAR / LEITURA").
- **Cada palavra surge no INSTANTE em que é narrada** (timestamps reais), com pop; as já ditas permanecem. Sem cor de karaokê — só o aparecer.
- Quebra de bloco por pontuação (`. , ? ! : ;`) ou a cada ~4 palavras.

## 2. Fonte
- **Montserrat Black (peso 900)**, **TODA MAIÚSCULA**.
- **Branca** (`#FFFFFF`), **sem contorno** (nada de WebkitTextStroke), só uma
  **sombra suave** para legibilidade (`text-shadow: 0 4px 22px rgba(0,0,0,0.9)`).
- **Palavras FORTES (impacto/emoção) em VERMELHO** (`palette.red #EF4444`); o resto branco. A lista vem de `emphasisWords` no `adConfig.ts` (comparação sem acento/maiúscula). NÃO usar dourado na legenda.
- Tamanho **grande: ~92px** (`font.size.huge`) calibrado para 1080px de largura.

## 2.1 Auto-fit — legenda NUNCA pode estourar a tela (REGRA DURA)
Palavra longa (ex.: "PROFISSIONALIZARAM") com fonte fixa vaza lateralmente. Para
NUNCA acontecer:
- A fonte é **calculada por bloco** a partir da **palavra mais longa**:
  `fitSize = clamp(44, min(huge≈92, floor(USABLE / (longestChars * K))))`, com
  `USABLE = VIDEO.width * 0.86` (~928px de margem segura) e `K ≈ 0.70`
  (largura média do glifo Montserrat Black caixa-alta ÷ fontSize).
- Todas as palavras do bloco usam o MESMO tamanho (fica limpo).
- `maxWidth: 90%` no container + `flex-wrap` como rede de segurança.
- **SEMPRE validar por still** a cena com a palavra mais longa antes do render cheio.
- Se ainda assim raspar, baixar `USABLE` (0.84) ou subir `K` (0.72). Nunca deixar
  entregar com texto cortado — é falha de entrega.

## 3. Como as letras aparecem
- **Palavra a palavra**: cada palavra surge no seu tempo com **fade + scale (0.8→1)** em ~0.15s. As anteriores ficam. Sem karaokê colorido.

## 4. Layout
- Texto **centralizado no MEIO da tela** (vertical + horizontal), não colado embaixo.
- **REGRA (Rafael, 2026-09-29): SEM link do site / endereço (ex.: `fiberoficial.com.br`) no vídeo.** Topo limpo — nada de site, marca ou chip. Só a legenda central (e a seta dupla do CTA no fim).
- Gancho de abertura pode usar uma **pílula bege arredondada** no topo (ex.: "LEMBRA DESSA ÉPOCA?").

## 5. Fundo e cor
- **Cinematográfico e ESCURO** (moody, iluminação quente/golden hour, muito preto).
- Alterna **B-roll escuro** com **cartelas pretas** só com texto centralizado.
- Paleta: **preto + branco + dourado/bege `#C6A06B`** (acento). Fundo base `#000000`.
- **REGRA (Rafael, 2026-09-29): SEM sobreposição escura por cima do vídeo** — nada de scrim, gradiente, vinheta, `drawbox` preto ou escurecer o take. O vídeo vai com as cores originais. A legibilidade vem só da **sombra suave da própria letra** (borda preta desfocada, `blur` só na borda). Validado no BARE FOOT 01: legenda branca lê bem até sobre tênis branco.

## 6. Transições de take
- Takes **curtos: 2 a 5s** (medido no AD01: cortes em 5.4/10.7/12/14.2/19.1/20.6/23.1/30.8s...).
- **Corte seco** predominante; **um flash/zoom rápido** em um ponto de virada (~35s).
- Crossfade curtíssimo entre B-rolls é aceitável.

## 7. Áudio
- **Trilha emocional que CRESCE ao longo do vídeo** — começa baixa, sobe até o
  clímax perto do fim (medido: RMS sobe de ~−27dB no início para ~−18dB no auge ~35–50s),
  depois fade-out. NÃO é volume constante.
- Loudness integrado do AD01 ≈ **−25.7 LUFS**, LRA ~11 (bem dinâmico/cinematográfico).
  Master final ainda em `loudnorm I=-14` para redes.
- **SEM efeito sonoro (whoosh) na transição de take** — o Rafael NÃO quer whoosh de corte.
  As transições são apenas visuais (corte seco). Voz sempre acima da música.

## 7.1 Efeitos sonoros por PALAVRA (word-triggered SFX)
Pontuar palavras-chave com um efeito no INSTANTE em que são narradas dá vida ao anúncio.
- **Mapa palavra→efeito** em `sfx-map.json` (comparação sem acento/caixa/pontuação contra os
  timestamps de `data/narration-timing.json`). Exemplos padrão:
  - `whatsapp` → `notify.wav` (ding de mensagem, 2 toques)
  - `pedido` / `venda` → `chaching.wav` (cha-ching de venda, estilo Shopify)
  - `cupom` / `vale-troca` → `coin.wav` (tilim de moeda)
  - `link` → `pop.wav` (clique curto)
- **Direito autoral:** NÃO usar o som OFICIAL de apps/marcas (WhatsApp, Shopify, iPhone) num
  anúncio — risco de marca/copyright. Usar equivalentes **sintetizados/royalty-free** que
  LEMBRAM o som. Só usar o oficial se o Rafael entregar o arquivo e assumir o risco.
- **Volume (voz SEMPRE acima):** efeitos curtos e discretos, volume embutido no .wav
  (~0.35–0.6 linear): `pop 0.35`, `coin 0.4`, `notify 0.5`, `chaching 0.6`.
  Mix com `amix=normalize=0` (senão o ffmpeg abaixa tudo) e master `loudnorm I=-14` no fim.
- **Bom senso:** no máximo ~1 efeito a cada 2–3s; efeito pontua, não vira trilha. NÃO usar whoosh em transição de take (só SFX por palavra).
- **Implementação:** os .wav ficam em `public/sfx/`; `build-sfx-cmd.mjs <id> <in.mp4> <out.mp4>`
  lê o mapa + timings e emite o comando ffmpeg (SÓ SFX por palavra, sem whoosh de transição) já com `loudnorm`. Gerar os .wav com ffmpeg (`sine`/`concat`/`tremolo`/`afade`).
- **Validar:** conferir energia (`volumedetect`) no instante de cada palavra-gatilho; ouvir de fone.

## 8. CTA (SEM card em código)
- **NADA de card/box animado feito em código no fim** — o Rafael NÃO quer isso.
- O fim é o **mesmo estilo do resto**: a última fala do roteiro (ex.: "...na sua loja hoje. O link está aqui embaixo.")
  aparece como legenda palavra-a-palavra sobre o último B-roll, com uma **seta dupla (chevron) branca piscando**
  perto da base. Sem glass card, sem botão, sem selo.

## Implementação (skill criar-video-banco-video / template remotion-video-ad-broll-narracao)
- `theme.ts`: carregar **Montserrat** (`@remotion/google-fonts/Montserrat`), `font.family`/`display` = Montserrat;
  paleta acento `green`→`#C6A06B`, `bg`→`#000000`; `font.size.lead` ≈ 64.
- `WordCaptions.tsx`: blocos de 2–4 palavras, `toUpperCase()`, cada palavra revelada no seu `w.start` (pop),
  fonte `huge` (~92), branco + sombra, centralizado (`inset:0; align/justify center`). Sem stroke, sem karaokê colorido.
- `Scrim.tsx`: **NÃO usar** (regra 2026-09-29: sem sobreposição escura). Remover `<Scrim/>` do `OsppAd`.
- `adConfig.ts`: `chips: []` (a legenda central já é o texto na tela).
- `OsppAd.tsx`: **remover `<BrandMark/>`** (regra 2026-09-29: sem link do site no vídeo).
- `OsppAd.tsx`: **remover `<CtaCard>`** (sem card em código); usar `EndChevron` (seta dupla piscando após `ctaStartSec`). `WordCaptions` roda até o fim. MusicBed com volume que **cresce** (base→peak ~0.82 da duração).
- `WordCaptions`: `emphasisWords` → palavras fortes em `palette.red`; comparação normalizada (sem acento/caixa).
- Whoosh em `public/sfx/whoosh.wav` (ffmpeg `anoisesrc=pink` + highpass/lowpass + afade), mixado
  em pós nos limites de beat.

Ver também: [[VIDEO-ADS-REMOTION-PIPELINE]], [[NARRACAO-ANUNCIOS-PLAYBOOK]], [[EDICAO-VIDEO-ANUNCIO-FFMPEG]].
