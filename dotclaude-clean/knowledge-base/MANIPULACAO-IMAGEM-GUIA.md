---
title: "Manipulação de Imagem — Guia Operacional (CLI + Python)"
category: "Desenvolvimento"
tags: [imagem, imagemagick, convert, webp, cwebp, ocr, tesseract, rembg, exiftool, pillow, opencv, pdf, crop, resize, otimizacao]
topic: "Receituário de manipulação, edição, recorte, conversão, otimização, OCR e remoção de fundo de imagens"
priority: medium
version: "1.0.0"
last_updated: "2026-08-22"
secrets_required: []
summary: "Receituário CLI-first para manipulação de imagem na máquina local: roteamento objetivo→ferramenta + comandos prontos. Ferramentas verificadas/instaladas em 2026-05-25 (ImageMagick 6, libwebp, tesseract por+eng, rembg+onnxruntime, exiftool, pngquant/jpegoptim/optipng/gifsicle, potrace, Pillow, OpenCV). Complementa PYTHON-LIBS-MIDIA.md (escolha de libs) e a skill /imagem."
---

# Manipulação de Imagem — Guia Operacional

> CLI-first. Para **escolha de bibliotecas Python** de mídia ver `PYTHON-LIBS-MIDIA.md`. Para **gerar/editar por IA** (texto→imagem) ver `NANO-BANANA-PRO-GEMINI-DOCUMENTACAO.md` + memória `chrome-bridge-gemini-imagens` (nota 2026-08-22: referência à ponte antiga chrome-bridge, hoje aposentada; essa memória não foi encontrada em outro lugar da KB — precisa revalidação, o equivalente atual de automação de navegador seria firefox-bridge). Fluxo guiado: skill **`/imagem`**.

## Gotchas (ler primeiro)
- **ImageMagick é a v6** → comando é **`convert`** (`mogrify`, `composite`, `identify`). **`magick` NÃO existe** nesta máquina.
- **Nunca sobrescrever o original.** Saída na pasta de sessão `~/Downloads/claude-<timestamp>/` (CLAUDE.md §3.6).
- **`rembg` mora em `~/.local/bin`** → se "command not found" após `/limpar`, re-exportar PATH (`export PATH="$HOME/.local/bin:$PATH"`; memória `local-bin-path-some-pos-reinstalacao`). Precisa do extra `[cpu]` (`pip install "rembg[cpu]"`) — só `rembg[cli]` instala o binário mas **não** o onnxruntime; 1ª execução baixa o modelo u2net (~170MB).
- **`convert -crop` deixa o "virtual canvas"** → sempre seguir com **`+repage`** senão o offset persiste.
- Após editar, **conferir visualmente** (`Read` na imagem) e medir: `identify -format '%wx%h %b' out.png`.

## Ferramentas instaladas (verificado 2026-05-25)
`convert`/`mogrify`/`composite`/`identify` (IM6) · `cwebp`/`dwebp` · `pngquant` · `jpegoptim` · `optipng` · `gifsicle` · `tesseract` (langs **por**+**eng**) · `rembg` (+onnxruntime CPU) · `exiftool` · `potrace` · `pdftoppm`/`pdfimages`/`pdftotext` · `ffmpeg`/`ffprobe` · Python **Pillow** + **OpenCV** + numpy.

## Roteamento objetivo → ferramenta
| Objetivo | Ferramenta | Observação |
|---|---|---|
| Recorte / resize / rotação / formato | `convert` | composição complexa → Pillow/OpenCV |
| Crop proporção / centralizado | `convert -gravity center -extent 1:1` | por conteúdo → OpenCV |
| Remover bordas vazias | `convert -trim +repage` | — |
| → WebP (web) | `cwebp -q 82` | animado → `img2webp`/`gif2webp` |
| Otimizar peso | `jpegoptim` (JPG) · `pngquant`/`optipng` (PNG) · `gifsicle` (GIF) | pngquant = lossy leve; optipng = lossless |
| OCR | `tesseract img out -l por+eng` | PDF texto → `pdftotext -layout` antes |
| Remover fundo (IA) | `rembg i in out` | fundo sólido → `convert -fuzz 10% -transparent <cor>` |
| EXIF (ler/limpar/editar) | `exiftool` | `-all=` remove tudo (privacidade) |
| Composição / watermark / máscara / texto | Pillow ou `convert -composite` | — |
| Visão (rosto, borda, contorno, geometria) | OpenCV (`cv2`) | — |
| PDF → imagem | `pdftoppm -png -r 200` (render) · `pdfimages -all` (extrai embutidas) | — |
| Imagem → PDF | `convert *.png saida.pdf` | — |
| Vídeo → frames / frame único | `ffmpeg -i v -vf fps=1 f%04d.png` | inspeção → `ffprobe` |
| Raster → SVG (vetorizar) | `potrace` (entrada PBM: `convert in.png in.pbm`) | só bitmap 1-bit |

## Receituário
```bash
SD=~/Downloads/claude-$(date +%Y%m%d-%H%M%S); mkdir -p "$SD"

# RECORTE / RESIZE
convert in.jpg -crop 800x600+100+50 +repage "$SD/crop.jpg"     # LxA a partir de (x,y)
convert in.jpg -gravity center -extent 1:1 "$SD/sq.jpg"         # quadrado central
convert in.jpg -resize '1080x1080>' "$SD/r.jpg"                 # cabe em 1080, só reduz
convert in.png -trim +repage "$SD/trim.png"                     # corta bordas uniformes
convert in.jpg -rotate 90 "$SD/rot.jpg"; convert in.jpg -flop "$SD/mirror.jpg"

# CONVERSÃO / WEBP
cwebp -q 82 in.jpg -o "$SD/out.webp";  dwebp in.webp -o "$SD/out.png"
convert in.png "$SD/out.jpg"                                    # qualquer formato↔formato

# OTIMIZAÇÃO (peso)
jpegoptim --max=85 --strip-all -d "$SD" in.jpg
pngquant --quality=65-85 --force --output "$SD/o.png" in.png    # lossy leve
optipng -o5 -dir "$SD" in.png                                   # lossless
gifsicle -O3 --lossy=80 in.gif -o "$SD/o.gif"

# OCR
tesseract in.png "$SD/texto" -l por+eng                         # → texto.txt
tesseract in.png stdout -l por --psm 6                          # direto no stdout

# REMOVER FUNDO (IA)
export PATH="$HOME/.local/bin:$PATH"
rembg i in.png "$SD/sem-fundo.png"                              # 1ª vez baixa modelo
convert in.png -fuzz 12% -transparent white "$SD/nofundo.png"  # alternativa p/ fundo sólido

# EXIF / PRIVACIDADE
exiftool in.jpg                                                 # ler
exiftool -all= -o "$SD/limpa.jpg" in.jpg                        # remover todo metadado

# PDF
pdftoppm -png -r 200 in.pdf "$SD/pag"                           # render → pag-1.png...
pdfimages -all in.pdf "$SD/img"                                 # extrai imagens embutidas
convert "$SD"/pag-*.png "$SD/junta.pdf"                         # imagens → PDF

# INSPECIONAR
identify -format '%f: %wx%h %b %[colorspace] %m\n' in.jpg
```

```python
# Composição / watermark / máscara — Pillow (heredoc, sem criar arquivo)
python3 - <<'PY'
from PIL import Image, ImageDraw, ImageFont
base = Image.open("in.png").convert("RGBA")
ov   = Image.new("RGBA", base.size, (0,0,0,0))
d    = ImageDraw.Draw(ov)
d.text((20,20), "© Marca", fill=(255,255,255,160))
out  = Image.alpha_composite(base, ov)
out.convert("RGB").save("/caminho/out.jpg", "JPEG", quality=88)
PY
```

```python
# Detecção de rosto / contorno — OpenCV (heredoc)
python3 - <<'PY'
import cv2
img = cv2.imread("in.jpg")
casc = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
faces = casc.detectMultiScale(cv2.cvtColor(img, cv2.COLOR_BGR2GRAY), 1.1, 5)
for (x,y,w,h) in faces: cv2.rectangle(img,(x,y),(x+w,y+h),(0,255,0),2)
cv2.imwrite("/caminho/faces.jpg", img); print(len(faces), "rosto(s)")
PY
```

## Lote
```bash
# mogrify edita in-place (CUIDADO) → sempre apontar -path para a pasta de sessão
mogrify -path "$SD" -resize 1080x1080\> -format webp *.jpg
# ou paralelizar com find
find . -name '*.jpg' -print0 | xargs -0 -P4 -I{} cwebp -q 80 {} -o "$SD/{}.webp"
```
Dezenas+ de imagens com lógica condicional → sub-agente `Agent` em paralelo.

## Remover suporte/pedestal colado embaixo da comida (caso difícil — testado 2026-05-25)
**Verdades duras (testadas):** nenhum modelo de matting (`u2net`, `isnet-general-use`, `birefnet-general`) exclui o suporte — a comida repousa sobre ele e o objeto conectado/saliente entra no recorte. Morfologia não separa (a base do suporte é larga, não um pé fino). Color-key amplo come queijo/áreas escuras (deu faixa branca em pizzas escuras). **IA de imagem (Gemini web grátis, gpt-image) REGENERA o prato** → fabrica comida diferente + marca d'água; inútil pra fidelidade. OpenRouter serve `google/gemini-2.5-flash-image`/`gpt-5-image` por API (funciona, mas é **pago** — precisa crédito).

**Receita que funciona (híbrido):**
1. Recorte `rembg -m birefnet-general` (SOTA; baixa ~973MB; exige `pip install "rembg[cpu]"`).
2. Ajustar **elipse** à comida (`cv2.fitEllipse` no maior contorno) e manter só o interior → preserva o miolo inteiro, **sem buraco**.
3. **Color-key** do cinza (LAB, `chroma<20`) **só na faixa inferior** (`rows > ymin+0.72·h`), onde só existe crosta dourada (alto croma, sobrevive) + suporte (cinza, sai).
4. Manter maior blob + feather.
Script de referência: `~/Downloads/ifood-padronizacao/padronizar.sh`.

## Presets de plataforma
- **iFood** (foto de item/cardápio): **4:3**, ideal **1200×900** (mín 800×600, nunca menos), **≤5 MB**, JPG/PNG, fundo neutro (cimento/madeira), prato centralizado (mobile corta as laterais), **sem texto/logo/marca d'água** sobre a comida.
