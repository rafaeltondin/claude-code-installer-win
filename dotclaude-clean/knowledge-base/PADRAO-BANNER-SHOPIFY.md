---
title: "Padrão Banner Shopify — banner de imagem + texto na home (seção slideshow)"
category: "Shopify"
tags:
  - shopify
  - banner
  - slideshow
  - home
  - liquid
  - css
  - suletiquetas
  - fiber
topic: "Como montar banner de imagem com texto sobreposto na home de um tema Shopify"
priority: high
version: "1.0.0"
last_updated: "2026-08-25"
secrets_required:
  - SHOPIFY_SULETIQUETAS_ADMIN_TOKEN
summary: "Receita testada para colocar banners de imagem+texto ao longo da home de um tema Shopify usando a seção nativa slideshow (mesmo mecanismo que a Fiber usa): campos do bloco, posição do texto, upload das imagens, imagem própria pra celular, e os 5 gotchas que fizeram o texto sumir e a margem preta aparecer."
---

# Padrão Banner Shopify — imagem + texto na home

> **FIBER:** este doc descreve a seção NATIVA `slideshow` (abordagem genérica, ex.: Sul Etiquetas).
> A home da FIBER hoje NÃO usa slideshow — usa seções custom `fiber-hero`/`fiber-banner`.
> Para banner na home da Fiber, ver **`FIBER-HOME-BANNERS-SECOES.md`**.

Receita validada em 25/08/2026 na loja Sul Etiquetas (tema Prestige-like, theme id
`195454566769`), replicando o padrão do banner "LANÇAMENTO OCTO COLORS" da Fiber.
Vale pra qualquer tema baseado em Prestige/Impulse com a seção `slideshow`.

## Conceito

O jeito CERTO NÃO é gambiarra de HTML/CSS num Custom Liquid — é usar a **seção
nativa `slideshow`** do tema, um bloco `image` por banner. O texto (eyebrow +
título + botão) é campo do bloco; o tema posiciona sobre a imagem. É exatamente
o que a Fiber faz (`fiber_banners_carousel` no `templates/index.json` dela).

Cada banner = 1 seção `slideshow` com 1 bloco `image`, ou várias slides num
carrossel só. Para banners espalhados AO LONGO da home, criar VÁRIAS seções
slideshow separadas e intercalar na `order` do `templates/index.json`.

## Campos do bloco `image` (settings)

- `image` — imagem desktop (2160x1080 .jpg recomendado; proporção larga ~2.3:1).
- `mobile_image` — imagem retrato pro celular (~750x1246). Se vazio, usa a desktop.
- `text_position` — `top/middle/bottom` × `left/center/right` (ex.: `middle_left`,
  `middle_right`, `bottom_center`). Vertical "middle" = centralizado.
- `subheading` — eyebrow (texto pequeno acima do título).
- `title` — título grande (1 linha só; o campo não aceita quebras).
- `button_1_text` / `button_1_link` — botão CTA.
- `text_color`, `button_background`, `button_text_color` — CORES vêm DAQUI, não do CSS.
- `title_font_size`, `subtitle_font_size` — tamanho base (px).

Onde posicionar o texto: analisar a imagem ANTES — o texto vai no espaço VAZIO
dela (se o produto está à direita, texto à esquerda, etc.).

## Passo a passo

1. Gerar/preparar as imagens. Para desktop, banner largo. Para celular, gerar
   imagem RETRATO própria com o elemento em cima (~55%) e uma área lisa embaixo
   (~45%) reservada pro texto — via IA (skill/`openrouter-image.mjs`, `--size 750x1246`).
2. Subir cada imagem pra Shopify Files (GraphQL `stagedUploadsCreate` → POST
   multipart → `fileCreate contentType:IMAGE` → poll até `fileStatus READY`).
   Script pronto: `/tmp/upload_categoria.py` do projeto (ou reescrever — está no
   histórico da sessão 25/08/2026). NÃO dá pra sobrescrever bytes de um arquivo
   existente de mesmo nome: subir arquivo NOVO (sufixo `-v2` etc.).
3. Editar `templates/index.json`: criar as seções `slideshow` (uma por banner),
   apontar `image`/`mobile_image` pra `shopify://shop_images/<arquivo>`, preencher
   textos/cores, e inserir os ids na lista `order` intercalando com as outras seções.
4. Publicar o `templates/index.json` e o `snippets/custom-css.liquid` via
   PUT `/admin/api/2025-01/themes/<id>/assets.json`.
5. VALIDAR AO VIVO no navegador (firefox-bridge), desktop E celular — ver gotchas.

## GOTCHAS (o que custou retrabalho — LER ANTES)

1. **Id da seção tem PREFIXO.** No DOM o id vira
   `shopify-section-template--<numero>__<chave-da-secao>` (ex.:
   `...template--29040314450289__slideshow_hero`). CSS mirando
   `#shopify-section-slideshow_hero` **NÃO PEGA NADA**. Usar seletor por sufixo:
   `[id$="__slideshow_hero"]`. Foi isso que fez todo o CSS de banner falhar em
   silêncio (no desktop o texto aparecia só porque o JS do tema revelava sozinho).

2. **O texto nasce INVISÍVEL.** O tema usa `[reveal]{opacity:0}` +
   `[reveal-visibility]{visibility:hidden}` e um JS de "revelar ao rolar" pra
   mostrar. Esse gatilho falha às vezes (e quase sempre no celular) → texto some.
   Fix: forçar visível no CSS, no texto e em TODOS os filhos:
   ```css
   [id$="__slideshow_hero"] .slideshow__text-wrapper,
   [id$="__slideshow_hero"] .slideshow__text-wrapper * {
     opacity:1 !important; visibility:visible !important;
     transform:none !important; animation:none !important;
   }
   ```

3. **Celular joga o texto numa faixa do MEIO** (só ~248px de altura, centralizada),
   que cai EM CIMA do elemento da imagem e some. Reposicionar pro rodapé real
   (a área lisa da imagem mobile):
   ```css
   @media (max-width:740px){
     [id$="__slideshow_hero"] .slideshow__slide-inner .container{position:absolute;inset:0;max-width:100%;padding:0}
     [id$="__slideshow_hero"] .slideshow__text-wrapper{position:absolute;left:0;right:0;bottom:0;top:auto;width:100%;height:40%;display:flex;align-items:center;justify-content:center;text-align:center;padding:0 20px 7%}
   }
   ```
   E ajustar a COR do texto pelo fundo da faixa de baixo: fundo azul → texto
   branco; fundo claro → texto escuro. (No desktop a cor pode ser outra, porque
   o texto cai noutra parte da imagem.)

4. **Margem/faixa preta embaixo do banner:** vem do tema calcular a altura do
   slide por uma variável de proporção (`--image-aspect-ratio` no
   `.slideshow__slide-inner:before`) que não bate com a imagem real. NÃO tentar
   resolver reescrevendo `.slideshow__image-wrapper` pra `position:relative`/
   `height:auto` — isso QUEBRA a animação de revelar e o texto some. Preferir
   deixar a proporção do bloco casar com a imagem, ou aceitar o corte via
   `section_height`. (Incidente 25/08: o hack de layout matou o texto.)

5. **Cor de botão e eyebrow vêm do BLOCO no template** (`button_background`,
   `button_text_color`, `text_color`), não do CSS. Pra trocar cor de botão,
   editar o `templates/index.json`, não o custom-css. Cor do título/eyebrow via
   `.heading--large`/`.heading--small` no CSS funciona (com o seletor por sufixo
   do gotcha 1).

## Fonte condensada estilo Fiber

A Fiber usa fonte paga (Typekit `bebas-neue-pro`). Substituto gratuito com o
mesmo ar condensado/impactante: **Oswald** (Google Fonts). `@import` no topo do
bloco `<style>` e aplicar `font-family:'Oswald','Montserrat',sans-serif` nos
`.heading--large/.heading--small` e no `.button` do banner.

## Cores da marca Sul Etiquetas
- Azul do logo: `#0068b0`
- Laranja do logo: `#F58635`
- Verde (usado em botão de compra/checkout, NÃO nos banners): `#2E9E7B`

## Cross-refs
- Loja/token: `~/.claude/knowledge-base/SHOPIFY-SULETIQUETAS.md`
- Imagens de produto por IA + upload Files: `~/.claude/knowledge-base/SULETIQUETAS-IMAGENS-PRODUTO-PADRAO.md`
- Template de banner overlay 100vw (abordagem Custom Liquid, alternativa): `~/.claude/knowledge-base/TEMPLATES-CODIGO-PADRAO.md`

## Banner de VÍDEO no carrossel (slideshow) — limitação e receita (rev 2026-09-09)

Testado na Fiber (tema Prestige 8.3.0, `fiber_banners_carousel`).

- **Limitação real da Shopify:** o campo nativo `video`/`mobile_video` (block type
  `video` da seção `slideshow`) NÃO pode ser setado por API. Tanto o Asset REST
  (PUT assets.json) quanto o GraphQL `themeFilesUpsert` rejeitam qualquer valor
  (`shopify://shop_videos/<arquivo>`, gid, id numérico, hash da CDN) com
  `"Setting 'video' value must be a valid video shopify url."`. Só o EDITOR VISUAL
  do tema seta esse campo. (Confirmado em log de terceiros também.)
- **Receita que funciona por API (sem editor):** editar a `slideshow.liquid` e
  adicionar no bloco `video` dois settings do tipo `text` (NÃO `url` — o tipo
  `url` descarta a URL da CDN e salva vazio), ex. `custom_desktop_mp4` /
  `custom_mobile_mp4`. No render do bloco, antes do check nativo, se o texto
  existir, imprimir `<video autoplay muted loop playsinline>` com `<source>` na
  URL `originalSource` da CDN (pega via GraphQL `node(Video){originalSource{url}}`).
- **Subir o vídeo:** `stagedUploadsCreate(resource:VIDEO)` → POST multipart →
  `fileCreate(contentType:VIDEO)` → poll `fileStatus READY`. Filename SEM espaço.
  Vídeo não pode ser renomeado depois (`fileUpdate` só imagem/genérico) — subir
  já com nome limpo.
- **max_blocks:** o `slideshow` da Prestige limita a 6 blocos (`"max_blocks":6`).
  Para um 7º banner, subir esse número no schema da seção.
- **GOTCHA de tamanho (o que me custou retrabalho):** NÃO pôr `style` inline com
  `display` no `<video>`. O CSS `.content-over-media>:is(img,video,...)` já
  dimensiona igual às imagens (object-fit:cover, height:auto). O inline `display`
  vence a classe `.sm:hidden`/`.hidden`, então os DOIS vídeos (desktop + mobile
  vertical) ficam visíveis e empilhados no mesmo grid-area, e o vertical (alto)
  estica o slide no desktop. Deixar só as classes `hidden sm:block` (desktop) e
  `sm:hidden` (mobile) controlarem a visibilidade, com os atributos `width`/
  `height` do vídeo pra dar a proporção certa por breakpoint.

## Gotcha (2026-09-11) — troca de foto por cor no card não funciona (Fiber/Prestige)
Causa: no `assets/theme.js`, `ProductCard.onSwatchChanged` chamava `querySelectorAll(\`a[href^="${this.product.url}"\`)` SEM o `]` de fechamento → seletor inválido → DOMException a cada mudança de swatch, abortando o swap da imagem (universal, todos os produtos). Fix: adicionar o `]` → `a[href^="${this.product.url}"]`. Pré-requisitos do swap (todos já ok na Fiber): cada variante de cor com `featured_media`, swatches dentro de `.product-card__info`, produto `active` (ProductLoader busca `/products/handle.js`). Backup antes de editar o theme.js minificado.
