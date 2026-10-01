---
title: "Fiber — Componente de Vídeos 'Stories' (página de produto e Fiber Academy)"
category: "Fiber"
tags:
  - fiber
  - shopify
  - prestige
  - product stories
  - tolstoy
  - video
  - liquid
  - metaobjects
  - fiber academy
summary: "Documenta o componente 'Product Stories' (carrossel de vídeos circulares estilo Instagram) do tema da Fiber — substituição nativa do Tolstoy — e a section derivada 'Vídeos (Stories)' implementada na página Fiber Academy em 2026-05-21. Arquivos, fonte de dados, IDs de tema/página e decisões técnicas."
secrets_required:
  - SHOPIFY_FIBER_ADMIN_TOKEN
  - SHOPIFY_FIBER_DOMAIN
---

# Fiber — Componente de Vídeos "Stories"

Loja: **fiber-knit-sport-br.myshopify.com** (www.fiberoficial.com.br), tema **Prestige 8.3.0** "tema-fiber", **main id `159906693337`**. Gotchas técnicos de Shopify usados aqui: [[SHOPIFY-THEME-API-MIDIA-CACHE-GOTCHAS]].

## 1. Componente original (página de produto)
Carrossel de miniaturas circulares que abre um modal fullscreen 9:16 estilo Instagram Stories. É **custom no tema** (comentário no código: *"native Shopify replacement for Tolstoy"*), não um app.

| Arquivo | Papel |
|---|---|
| `snippets/product-stories.liquid` | markup + leitura dos dados |
| `assets/product-stories.css` | tiles circulares 96px, scroll-snap, modal 9:16, barras de progresso |
| `assets/product-stories.js` | web component `<product-stories>` (autoplay no hover via IntersectionObserver, modal, swipe, teclado) |
| bloco `product_stories` em `sections/main-product.liquid` | schema (settings `tile_size`, `show_titles`); render em `snippets/product-info.liquid` (`{% when 'product_stories' %}`) |

**Fonte de dados:** `product.metafields.custom.stories` → lista de **metaobjects `product_story`** (campos `video`, `poster`, `title`), cadastrados em *Content → Metaobjects*. Por isso só aparece em produtos com esse metafield preenchido. Ex. de produto com template dedicado: `templates/product.strap-python-maxgrip.json`.

## 2. Implementação na Fiber Academy (2026-05-21)
Página **`/pages/fiber-academy`** (page id `132209836249`, template **`page.treinamento-representante`**). A página só tinha slideshows + rich-text; foi adicionada uma galeria de vídeos dos 20 produtos como material de treinamento de representantes.

Arquivos criados no tema:
| Arquivo | Papel |
|---|---|
| `sections/page-video-stories.liquid` | section "Vídeos (Stories)" — custom element **`<video-stories>`**; lê os vídeos de **blocks** (não de metaobjects); envolve no wrapper Prestige (`.color-scheme` + `.container--{width}` + `.prose`) |
| `assets/page-video-stories.css` | overrides que seguem o color-scheme do tema (`rgb(var(--text-color))`, `rgb(var(--background))`), `tile_size` configurável, **spinner de loading** e **botão de som** |
| `assets/page-video-stories.js` | web component **`<video-stories>`** (separado do `product-stories` para não afetar a página de produto) |

Cada block tem: `title`, `poster` (URL img), `video_small` (mp4 480p, tile), `video_large` (mp4 720p, modal). A section foi inserida no template logo após a section de intro "FIBER ACADEMY".

### Decisões técnicas (e porquês)
- **Vídeos**: 20 criativos de produto comprimidos localmente (HEVC/libx265 CRF 20, ~77% menor) e então subidos como **Shopify VIDEO** (transcoda p/ H.264 mp4 480/720/1080 + HLS). HEVC direto não tocaria em Chrome/Firefox.
- **Modal usa 720p** (não 1080p): o 1080p (2.5 Mbps) ficava em `readyState 0` por ~6s e não iniciava; 720p (1.6 Mbps) inicia quase instantâneo.
- **Autoplay robusto**: ao abrir tenta tocar com som; se o navegador bloquear, inicia **mudo** (garantido) + botão de som para reativar.
- **Loading overlay** (spinner) visível enquanto `waiting`/sem dados; some no `playing`/`timeupdate`.
- **CSS segue o tema**: variáveis do Prestige em vez de cores fixas, para integrar visualmente à página.

## 3. Cópia de trabalho
Para revisão sem afetar a loja: tema **"FIBER ACADEMY VÍDEOS — draft"** (criado via `themeCreate` + zip do backup). A feature foi validada nessa cópia (preview) e depois aplicada ao tema publicado. Backup do tema original em `~/Área de trabalho/backup-tema-fiber-*/`.

> Após aplicar no tema publicado, o storefront público demora a refletir por causa do `page_cache` distribuído do Shopify (ver [[SHOPIFY-THEME-API-MIDIA-CACHE-GOTCHAS]] §7). Validar pela Admin API / preview, não só pelo curl público.
