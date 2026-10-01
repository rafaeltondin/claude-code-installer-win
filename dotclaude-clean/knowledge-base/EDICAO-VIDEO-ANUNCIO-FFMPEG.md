---
title: "Edição de Vídeo de Anúncio (Reels/Meta) com ffmpeg — Pipeline VO-Spine"
category: "Automacao"
tags: [ffmpeg, video, anuncio, reels, meta-ads, elevenlabs, legenda, ass, karaoke, forced-alignment, montserrat, criativo, vertical, tts]
topic: "Montar anúncio vertical 9:16 a partir de takes filmados + narração TTS, com legenda sincronizada"
priority: high
version: "1.3.0"
last_updated: "2026-07-30"
secrets_required: [ELEVENLABS_API_KEY]
summary: "Pipeline ffmpeg para transformar takes brutos de câmera + narração ElevenLabs em anúncio vertical pronto pro Meta: VO como spine (timestamps por frase/palavra via forced-alignment), corte e normalização 9:16, concat demuxer, legenda .ass karaokê em Montserrat sincronizada por palavra, áudio cru (sem loudnorm), lead-in/out, export H.264 faststart. Inclui gotchas de WSL/9p e do TTS descobertos na produção dos criativos da Sapatilha Fiber."
---

# Edição de Vídeo de Anúncio com ffmpeg — Pipeline VO-Spine

> Quando usar: montar criativo de vídeo vertical (Reels/Meta/TikTok) a partir de **takes filmados** (B-roll sem fala) + **narração TTS**, com legenda sincronizada palavra a palavra. Origem: produção dos anúncios da Sapatilha Fiber Training (2026-05-30), 6 variantes geradas.
> Complementos: copy em `COPY-PERSUASAO-STORYTELLING-ANUNCIOS.md`, brand voice em `FIBER-VOZ-TOM-BRAND-VOICE.md`, API de voz em `ELEVENLABS-API.md`.

## Princípio mestre: a narração é a régua (spine)

Não se corta o áudio pra caber no vídeo — **corta-se o vídeo pra caber em cada frase da narração**. Fluxo:
1. Gera a VO (TTS).
2. Pega timestamp de início/fim de cada **frase** (slots) e de cada **palavra** (legenda) via forced-alignment.
3. A duração de cada slot vira a duração-alvo do take daquela cena.
4. Vídeo e áudio terminam juntos, naturalmente sincronizados.

## Passo 1 — VO + timestamps (ElevenLabs)

- TTS com timestamps: `POST /v1/text-to-speech/{voice}/with-timestamps` → retorna `audio_base64` + `alignment` (chars + `character_start_times_seconds`/`..._end...`).
- Alternativa (áudio já existe): `POST /v1/forced-alignment` (multipart: `file` + `text`) → `{characters, words, loss}`. `loss` < 0.1 = bom alinhamento.
- **Slots por frase:** localizar cada frase na string concatenada de chars (`full.find(p, pos)`) e pegar `start` do 1º char / `end` do último.
- Settings que NÃO mudam timbre/cadência (preferência Fiber): `stability 0.45, similarity_boost 0.8, style 0.15, use_speaker_boost true`, **sem `speed`**.

### GOTCHA — forced-alignment/with-timestamps duplica palavras
A API às vezes retorna a lista `words` com **cada palavra duplicada** (ex.: 153 entradas para 77 palavras reais) e **espaços como tokens próprios**. Sempre:
```python
words=[]; seen=None
for x in raw_words:
    t=x.get("text","").strip()
    if not t: continue                      # ignora espaços
    k=(round(x["start"],3),round(x["end"],3),t)
    if k==seen: continue                     # dedup consecutivo
    seen=k; words.append({"text":t,"start":x["start"],"end":x["end"]})
```
Mais robusto ainda: **rederivar as palavras a partir de `characters`** (cada char tem text/start/end), agrupando por espaço — evita qualquer duplicação da lista `words`.

## Passo 2 — Cortar + normalizar cada take (filtro obrigatório)

Takes de câmera vêm em resoluções diferentes (4K, 2816×1584) mas verticais. Para concatenar sem glitch, **todo clipe** passa pelo mesmo filtro:
```
scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,fps=30,format=yuv420p
```
Corte: `ffmpeg -ss <IN> -i take.mov -t <DUR> -vf "<filtro>" -an -c:v libx264 -preset medium -crf 19 -video_track_timescale 30000 clip_N.mp4`
- `-an` remove o áudio do take (só a VO entra depois).
- `-video_track_timescale 30000` uniformiza timebase → concat demuxer não dá salto.

## Passo 3 — Escolher os MELHORES trechos (contact sheet)

Não chutar o `IN` de cada take. Gerar tira de contato com timestamp gravado em cada frame:
```bash
for t in $(seq 1 <passo> <dur>); do
  ffmpeg -ss $t -i take.mov -frames:v 1 \
    -vf "scale=120:-1,drawtext=text='${t}s':x=3:y=3:fontsize=15:fontcolor=yellow:box=1:boxcolor=black@0.6" f_$t.jpg
done
convert f_*.jpg +append STRIP.jpg   # tira horizontal; ler com a tool Read
```
Ler a tira (via Read), achar a janela com o melhor movimento/iluminação, definir `IN`. Muitos takes têm trechos escuros/borrados — sempre conferir antes. Casar a cena com o texto (ex.: legenda "SOLA FINA" sobre o frame que mostra a sola).

## Passo 4 — Concat

```bash
printf "file 'clip_1.mp4'\nfile 'clip_2.mp4'\n..." > concat.txt
ffmpeg -f concat -safe 0 -i concat.txt -c copy video_only.mp4
```

## Passo 5 — Áudio: CRU, sem loudnorm

**NUNCA passar `loudnorm` na voz** — ele reprocessa, comprime a dinâmica e altera timbre/cadência (perceptível na hora). Usar o MP3 cru, só fade-out suave no fim:
```bash
ffmpeg -i vo.mp3 -af "afade=t=out:st=<total-0.4>:d=0.35" -c:a pcm_s16le vo_final.wav
```
Para **lead-in/out** (respiro antes/depois da fala): `adelay=500|500` (0,5s antes) + `apad` + `-t <video_total>`. Preferência Fiber: 0,5s antes, ~2s depois. Quando há lead-in, **deslocar as legendas** em +lead_in.

## Passo 5b — FLUIDEZ: cortar o silêncio excedente (validado 2026-07-30)

**Sintoma:** narração soa arrastada, "muito espaço" entre as frases. Medição real numa leva de
5 anúncios: **29% do tempo era silêncio**, com pausas de até **0,73 s** entre frases — o
ElevenLabs insere pausa longa em todo `.`, `:` e travessão.

**Três correções, em ordem de impacto:**

1. **Cortar o silêncio AUDÍVEL, não o gap do alignment.** Esse é o ponto principal: o
   decaimento da voz cai abaixo do limiar audível **antes** do `end` oficial da palavra no
   alignment, então o silêncio percebido é maior que o calculado. Usar `silencedetect` no MP3
   (`noise=-38dB:d=0.10`), cortar o excesso e **remapear os timestamps** de palavras/frases
   pelos cortes acumulados (`novo_t = t - soma_dos_cortes_antes_de_t`). Cortar pelo alignment
   só levou 29%→20%; cortar pelo silêncio audível levou a ~3 s a menos por peça.
   - Limites que funcionaram: **0,17 s** entre palavras/frases, **0,32 s** antes do CTA
     (pausa intencional — "a pausa cria peso", playbook de narração), **0,045 s** de borda
     preservada nas pontas de cada corte (senão corta o ataque da palavra e dá clique).
   - Reconstruir o áudio com `atrim`+`concat` (não `atempo`/`silenceremove`): preserva pitch,
     timbre e cadência — só remove pedaço de silêncio.
2. **Settings certos da voz.** Usar os da preferência Fiber (§Passo 1), NÃO o perfil
   "VSL/narração informativa" do doc geral do ElevenLabs — `speed 0.95` deixa a fala inteira
   lenta, e `stability 0.6` engessa a cadência.
3. **Pontuação enxuta no texto do TTS.** Travessão vira vírgula; evitar ponto final no meio
   da ideia. Ganho isolado é pequeno (~4 p.p.), mas soma.

**Resultado:** 21,0 s → 17,3 s na mesma peça, sobrando **só 3 silêncios, todos intencionais**
(lead-in ~0,55 s, pausa do CTA ~0,32 s, cauda ~1,2 s).

### Cenas por BLOCO de fala, não por frase
Depois de enxugar a pontuação as frases ficam longas (4-5 s), o que dá cena arrastada para
Reels. Quebrar cada frase em **blocos de ~2,8 s** nas vírgulas/dois-pontos internos
(e partir ao meio o que passar de ~4,5 s sem vírgula). Saiu de 6 para 7-8 cortes por peça.

### Verificação objetiva da sincronia (sem ouvir)
Dois âncoras que o `silencedetect` dá de graça no MP4 final: o **1º `silence_end`** é o
início da fala e o **2º** é o início do CTA. Comparar com o 1º evento do `.ass` e com o evento
do bloco do CTA. Na leva validada o pior desvio foi **108 ms**, sempre com a legenda entrando
*antes* da fala (direção correta). Cruzar com Whisper local também funciona, mas o `segment
start` do Whisper antecipa o começo da fala e gera falso desvio de ~300 ms — não usar como
métrica fina.

### GOTCHA — legenda duplicada na tela entre blocos
Se o último evento de um bloco estende `w.end + margem` sem limite, ele **invade o bloco
seguinte** e aparecem duas legendas sobrepostas no vídeo (só se vê extraindo frame — não
acusa erro em lugar nenhum). Limitar sempre: `fim = min(w.end + margem, proximo_bloco.start - 0.02)`.

## Passo 6 — Legenda .ass karaokê (Montserrat)

Duas abordagens comprovadas para legenda sincronizada:

### Abordagem A — `\kf` Karaokê (destaque linear)

Legenda = **texto idêntico à narração**, palavra a palavra, com `\kf` (a palavra falada acende; o resto fica na cor secundária). Estilo aprovado:
- Fonte **Montserrat ExtraBold**, tamanho ~74, `PrimaryColour &H00FFFFFF` (branco), `SecondaryColour &H009A9A9A` (cinza), outline 6.
- **Sem ponto final** — só vírgulas: `wt = w["text"].upper().replace(".","")`.
- Agrupar palavras em chunks de ≤3 ou quebra em pontuação.

### Abordagem B — Revelação cumulativa com `\c` (preferida para anúncios diretos)

Alternativa ao `\kf`: usar `\c` para colorir palavras não-faladas em cinza, mantendo as já faladas em branco. Efeito mais limpo e sutil que o karaokê tradicional, validado nos criativos da Sapatilha Fiber (2026-06-01).

```
Cada frase gera 3 linhas de legenda:
1. Palavra 1 em branco, restante em cinza:
   {\c&H00FFFFFF}PRIMEIRA {\c&H00A8A8A8}SEGUNDA TERCEIRA
2. Palavras 1-2 em branco, última em cinza:
   PRIMEIRA SEGUNDA {\c&H00A8A8A8}TERCEIRA
3. Todas em branco (frase completa):
   PRIMEIRA SEGUNDA TERCEIRA
```

**Style:** `Montserrat ExtraBold`, `74px`, `PrimaryColour &H00FFFFFF` (branco), `SecondaryColour &H00A8A8A8` (cinza para não-faladas), `\blur2` (glow sutil), `\fad(60,40)` (fade in/out nas transições de frase), `MarginV=430` (posição ~24% do rodapé — mais alta que centralizada), `Outline 2`, `Shadow 4`.

**Prós:** visual mais "limpo" que `\kf`; o espectador vê a frase completa gradualmente. **Contras:** mais eventos no .ass (3 por frase vs 1 no `\kf`).

### Abordagem C — Escala por palavra (`\t` + `\fscx/\fscy`) — validada 2026-07-30

Quando o pedido é "a palavra falada AUMENTA, só as letras dela": gerar **um evento `Dialogue`
por palavra**, em que apenas a palavra corrente recebe a animação de escala e as demais do
bloco ficam em 100%:

```
Dialogue: 0,{ini},{fim},Leg,,0,0,0,,{\fscx100\fscy100}PALAVRA1 {\fscx100\fscy100\t(0,90,\fscx138\fscy138)}PALAVRA2 {\fscx100\fscy100}PALAVRA3
```

- `\t(0,90,...)` anima 100%→138% em 90 ms (crescimento suave, não "pula").
- O evento de cada palavra termina **quando a próxima começa** (`fim = prox.start`), não no
  `end` dela — senão aparecem buracos sem legenda entre as palavras.
- Centralizada na tela = `Alignment 5` no Style (o `MarginV` deixa de importar).
- **Contorno forte é obrigatório**: com `Outline 5` o texto branco sumia sobre a barra do
  agachamento e sobre piso claro. `Outline 7` + `Shadow 4` resolveu.
- Blocos de **≤3 palavras e ≤17 caracteres** — acima disso a linha compete com a imagem.

### GOTCHA — bloco de legenda não pode cruzar fronteira de frase
Se o agrupamento em chunks olhar só pontuação/contagem, o fim de uma frase gruda no começo
da seguinte ("DESCALÇA E O"). Agrupar as palavras **por frase primeiro**, depois chunkar
dentro de cada frase.

### GOTCHA — take sem material suficiente para a cena
Cena longa (CTA com "e resolva") + take curto = corte estoura o fim do arquivo. O builder
deve **recuar o `in` automaticamente** (`in = dur_take - duração_necessária`) e só abortar se
nem o take inteiro couber — aí é caso de trocar de take.

### GOTCHA — campo `Name` no .ass
A linha `Format:` de `[Events]` PRECISA incluir o campo `Name` entre `Style` e `MarginL`:
`Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text`
Se omitir, os campos deslocam e aparece **uma vírgula no começo de cada legenda** (`,TEXTO`). As linhas `Dialogue:` têm o campo vazio: `Dialogue: 0,{start},{end},Leg,,0,0,0,,{texto}`.

### Fonte Montserrat no WSL (não vem instalada)
GitHub `google/fonts` e jsDelivr deram 404; Windows não tinha. Que funcionou: **API CSS do Google Fonts** → pega URL real do gstatic:
```bash
curl -fsSL -A "Mozilla/5.0" "https://fonts.googleapis.com/css2?family=Montserrat:wght@700;800" -o m.css
grep -oE "https://[^)]+\.ttf" m.css   # baixar esses TTF pra ~/.fonts e fc-cache -f
```
No ffmpeg, apontar a pasta: `ass=subs.ass:fontsdir=~/.fonts`.

## Passo 7 — Mux final (specs Meta)

```bash
ffmpeg -i video_only.mp4 -i vo_final.wav \
  -filter_complex "[0:v]ass=subs.ass:fontsdir=~/.fonts[v]" \
  -map "[v]" -map 1:a -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p \
  -c:a aac -b:a 192k -ar 44100 -movflags +faststart -shortest out.mp4
```
Resultado: 1080×1920 · H.264 · 30fps · AAC 192k · faststart (sobe direto no Meta/Reels).

## Passo 8 — Cauda muda de ~1s (pós-narração)

Para evitar que a voz acabe junto com o vídeo (sensação de corte seco, comum em anúncios):

1. **Estender o último clipe** em +1s no corte:
   ```bash
   ffmpeg -ss <IN> -i take.mov -t <dur_original_mais_1> ... clip_N.mp4
   ```
   Isso cria ~1s de vídeo sem áudio após o fim da narração.
2. **NÃO usar `-shortest`** no mux final. Sem `-shortest`, o ffmpeg usa a duração do stream mais longo (vídeo), e o áudio termina naturalmente com silêncio:
   ```bash
   ffmpeg -i video_only.mp4 -i vo_final.wav \
     -filter_complex "[0:v]ass=subs.ass[v]" \
     -map "[v]" -map 1:a -c:v libx264 -preset medium -crf 18 \
     -c:a aac -b:a 192k out.mp4
   # sem -shortest → vídeo 37.6s, áudio 36.4s →
   ```
3. As legendas devem terminar ~0.5-1s antes do corte final do vídeo (último evento .ass antes do tail).

## Gotchas do TTS na narração (vozes específicas)

- **Elisão de vogais trava o TTS:** "que faz toda **a** diferença" saiu com pronúncia errada na voz Lendário (mas ok na Carla). **Fix: reformular a frase** ("que muda tudo") — mais robusto que grafia fonética, e vale pra qualquer voz. Vozes diferentes tropeçam em pontos diferentes.
- **Estrangeirismos** (Fiber, Training, zero drop): se sair errado, reescrever foneticamente **só no texto do TTS** (ex.: "drópi") e manter a grafia correta na legenda via mapa `{"DRÓPI":"DROP"}`. (No caso Fiber não foi necessário.)
- Validar o texto da narração **com o usuário ANTES de gerar áudio** — economiza rodadas.

## Verificação (sem ouvir o áudio)

- Loudness: `ffmpeg -i out.mp4 -af volumedetect -f null - 2>&1 | grep mean_volume` — áudio cru ElevenLabs fica ~−25 dB (fem) / −19 dB (masc). Se vier ~−14, passou loudnorm sem querer.
- Silêncios (lead-in/out): `ffmpeg -i out.mp4 -af silencedetect=noise=-40dB:d=0.3 -f null -`.
- Legenda: `grep '^Dialogue' subs.ass | sed 's/{[^}]*}//g'` mostra o texto exibido (sem os códigos `\kf`/`\fad`).
- Frames: extrair JPG/PNG em tempos-chave e ler via tool Read pra conferir take + legenda casados.

## Infra / performance (WSL)

- Processar **tudo no disco Linux** (`~/Downloads/...`), copiar só o MP4 final pro `/mnt/c`. Build pesado lendo direto do mount 9p trava.
- Rodar o build em **background** (`nohup python3 -u build.py &`) + `Monitor` no log com `grep` de `MUX|DONE|rc=[1-9]|Error`. `-u` (unbuffered) no python senão o log fica vazio.
- Um build de 6 clipes 4K→1080p + mux com legenda leva ~1–2 min.

> Ver também gotchas de WSL/9p e Python em `~/.claude/CLAUDE.md` §0 (Gotchas de Ferramentas).

## Seleção de takes/frames para anúncio (regra — aprendizado 2026-08-31, criativos Sapatilha Fiber)

Erro cometido e corrigido: montagem com trechos repetitivos (a mesma caixa sendo ABERTA e depois FECHADA em cenas separadas) e com o rosto da modelo em CARETA (frames no meio da fala num anúncio SEM narração). Regras obrigatórias ao escolher os trechos:

1. **Sem repetição de ação/objeto.** Um único momento de revelação do produto por peça — não mostrar abrir E fechar a caixa, nem vários closes quase iguais do mesmo item. Cada cena tem que agregar algo novo.
2. **Nada de careta/boca falando.** Em anúncio sem voz, NÃO usar takes em que a pessoa está falando (boca mexendo = careta congelada). Se precisar do rosto, escolher frame COMPOSTO (sorrindo ou neutro, olhando pra câmera), nunca no meio da palavra. Na dúvida, trocar o take falante por pose confiante ou ação.
3. **Priorizar movimento/ação e poses confiantes.** Treino (máquina, kettlebell, terra, caminhada com peso) e portrait firme convertem mais que cena parada, hesitante ou de transição.
4. **Sempre revisar tira de contato** (frames com timestamp gravado, 1 a cada ~2,5 s) ANTES de fixar o `in`. Descartar: borrado, escuro, sujeito saindo do enquadramento, meio de gesto feio. Escolher o ponto nítido e bem enquadrado.
5. **Variar enquadramento entre cenas vizinhas** (wide de corpo ↔ detalhe do pé/produto). Não emendar duas cenas parecidas.
6. **Validar o resultado olhando frames-chave** (extrair JPG e ler) — não confiar só na duração; conferir que nenhuma cena caiu em careta/borrão.

## Nota 2026-09-29 — Legenda AD01 só com ffmpeg/libass (sem Remotion)
- Caso: BARE FOOT 01 (13s, 3 narrações). Script reutilizável: `~/Downloads/sabe-arquivo-barefoot-1-pasta-transferir/montar_videos.py` (cópia deste padrão: cada palavra = 1 evento ASS com `\pos` medido por PIL, pop `\alpha`+`\fscx80→100` sem empurrar as vizinhas; blur só na borda = sombra suave; seta dupla em `\p1` piscando após o CTA; trilha com `volume='a+b*t/dur':eval=frame`).
- GOTCHA: libass desenha a Montserrat Black com em = **0.636 × \fs** (não 0.82 do ascent+descent). Medir com PIL em px de em e escrever `\fs = em/0.636`; senão letra sai pequena e o espaço entre palavras fica largo. Recalibrar para outra fonte renderizando 1 palavra sobre fundo preto.
- REGRA 2026-09-29: NADA de escurecer o vídeo (sem drawbox/vignette/scrim) e NADA de link do site na tela — ver VIDEO-ADS-PADRAO-AD01-CINEMATOGRAFICO.md §4-5. Legenda legível só com a sombra desfocada da borda da letra (Outline 6 preto 70% + \blur10), inclusive sobre tênis branco.
- Narração maior que o vídeo: `speed` até 1.2 no eleven_multilingual_v2; em 1.2 às vezes embola nome estrangeiro ("Barefoot") — regerar e conferir via whisper.rafaeltondin.com.br.
