---
title: "Fiber — Subir/editar banner na home (seções custom fiber-hero/fiber-banner)"
category: "Shopify"
tags:
  - fiber
  - shopify
  - home
  - banner
  - fiber-banner
  - fiber-hero
  - index.json
  - liquid
  - files
  - widescreen
  - mobile
topic: "Como subir e editar banners da home da Fiber pelo Admin API, no padrão de seções custom do tema (não o slideshow)"
priority: high
version: "1.0.0"
last_updated: "2026-09-29"
secrets_required:
  - FIBER_SHOPIFY_SHOP
  - FIBER_SHOPIFY_ADMIN_TOKEN
summary: "Padrão real de banner da home da Fiber: seções custom fiber-hero/fiber-banner (NÃO o slideshow do tema, que fica preto), upload de imagem pros Files, edição da ordem em templates/index.json, os 2 gotchas de API que custam retrabalho (Shopify descarta setting novo se o schema ainda não foi reconhecido; cache de settings do index.json), o selo opcional no padrão do fhero__selo, e as regras de CSS de altura que evitam corte em widescreen e no celular."
---

# Fiber — Banner da home (seções custom)

> **ATUALIZAÇÃO 2026-09-30:** o tema publicado passou a ser **167127285977** e a home agora é a seção `fiber-home-energia` (o banner Pulse está dentro dela, com animação). Este doc descreve o tema anterior 166850035929 (guardado como 'ANTES home energia'). Ver memória fiber-tema-teste-home-energia e KB MOTION-ANIMACOES-CODIGO.md §11.

Tema publicado (produção): **166850035929** ("FIBER | Prestige 8.3.0 | Producao perf ..."). Sempre confirmar o `main` ao vivo antes (`GET /admin/api/2024-04/themes.json`, role=main) — o número muda a cada republicação de tema.

## Regra de ouro
Na home da Fiber, banner NÃO usa a seção `slideshow` do tema (fica invisível/preto no cliente por causa do `[reveal]`+JS de revelar-ao-rolar). Usa seções **custom**:
- `sections/fiber-hero.liquid` — hero principal (aceita vídeo com poster; ex.: Semana do Cliente). Tem o selo "PRORROGADO" (`.fhero__selo`).
- `sections/fiber-banner.liquid` — banner de imagem reutilizável (Maxis, Pulse). Imagem desktop+mobile por NOME de arquivo (setting texto → `file_url`), texto/eyebrow/botão por settings, selo opcional.

Memórias relacionadas: `fiber-home-banners-custom`, `fiber-home-cache-template-json`. Doc do slideshow genérico (outras lojas): `PADRAO-BANNER-SHOPIFY.md`.

## Passo a passo (banner de imagem via fiber-banner)

1. **Preparar arte.** Desktop largo (a Fiber usa 1800x697) + mobile retrato (750x1246). O `fiber-banner` já traz esses `width/height` nos `<img>`.
2. **Subir pros Files** (GraphQL): `stagedUploadsCreate(resource:IMAGE)` → POST multipart pro bucket → `fileCreate(contentType:IMAGE, filename:"nome-sem-espaco.jpg")` → poll `node(MediaImage){fileStatus}` até `READY`. Nome sem espaço (ex.: `banner-desktop-pulse.jpg`). Não dá pra sobrescrever bytes de arquivo existente — subir nome novo.
3. **Editar `templates/index.json`.** Adicionar a seção em `sections` e o id na lista `order` na posição desejada (order[0] = primeiro da home). Padrão de uma instância `fiber-banner`:
   ```json
   "fiber_banner_pulse": {
     "type": "fiber-banner",
     "settings": {
       "image_desktop_file": "banner-desktop-pulse.jpg",
       "image_mobile_file": "banner-mobile-pulse.jpg",
       "link": "/products/<handle>",
       "align": "right",
       "eyebrow": "", "title": "", "button_text": "",
       "selo_titulo": "NOVO", "selo_sub": "LANÇAMENTO", "selo_cor": "#d71f3f"
     }
   }
   ```
   Se a arte já tem texto/botão embutidos, deixar `eyebrow/title/button_text` vazios (a seção só renderiza o overlay se preenchido). Selo idem: só aparece se `selo_titulo`/`selo_sub` preenchidos.
4. **Publicar** via `PUT /admin/api/2024-04/themes/<id>/assets.json` (payload `{"asset":{"key":"templates/index.json","value":"<json como string>"}}`). Backup do index.json ANTES (é a reversão em 1 passo).
5. **Validar ao vivo** (Playwright/Chromium headless) em desktop E mobile.
6. **Registrar** no changelog (`fiber-registrar-mudanca.py`, com `</dev/null` senão trava) e na base Tasks do Notion (`fiber-tarefa-notion.mjs`). Regra §15 do CLAUDE.md.

## GOTCHAS de API (custaram retrabalho em 2026-09-29)

1. **Shopify DESCARTA setting novo de seção salvo junto com o index.json.** Ao adicionar um setting que só existe no schema de uma versão NOVA da seção `.liquid`, se o PUT do `index.json` acontece no mesmo instante que o PUT da seção, a Shopify valida contra o schema ANTIGO (ainda em cache) e **remove** os campos desconhecidos silenciosamente (a `order` reflete, os settings não). **Fix:** PUT a seção `.liquid` PRIMEIRO; depois reenviar o `index.json` (um 2º PUT já com o schema reconhecido). Conferir relendo o index do servidor.
2. **Cache de settings do index.json** (memória `fiber-home-cache-template-json`): edição de `index.json` por API às vezes não reflete na home pública (motor preso numa versão antiga do parse). Edição de `sections/*.liquid` reflete na hora. A prévia autenticada (`?preview_theme_id=`) sempre lê o arquivo certo. Destrava público: abrir o personalizador e clicar **Salvar** (ação física do Rafael). Por isso `fiber-banner` lê imagem por NOME de arquivo (`file_url`), pra escapar desse cache.

## CSS de altura — evitar corte (widescreen e celular)

Banner de imagem com texto EMBUTIDO na arte não pode cortar. Erros e fixes validados:
- **NÃO usar altura fixa + `object-fit:cover`.** `fiber-banner` tinha `height: clamp(...640px)` com imagens `position:absolute; object-fit:cover` → em tela larga (>~1670px) a proporção do container passava a da arte e cortava topo/base (o eyebrow sumia em cima, o produto embaixo).
- **Deixar a imagem ditar a altura:** imagem em fluxo normal (`position:relative; width:100%; height:auto; display:block`) e seção `height:auto`. Aí a altura segue a proporção da arte (a Fiber: 2.58 no desktop) em qualquer largura, zero corte. É a mesma lógica que o `fiber-hero` sempre usou.
- **Celular — full-bleed:** mesmo com `height:auto`, o tema aplica ~12px de padding lateral, e a imagem fica mais estreita (366 de 390) → mais baixa. Forçar borda a borda:
  ```css
  @media screen and (max-width: 749px) {
    #fbnr-<uid> { width: 100vw; margin-inline: calc(50% - 50vw); padding-inline: 0; }
    #fbnr-<uid> .fbnr__media--mob { width: 100vw; max-width: none; height: auto; }
  }
  ```
  Resultado: imagem 100vw (390) × altura real (648), altura total, sem scroll horizontal.

## Selo (tarja tipo "PRORROGADO"/"NOVO")
O `fiber-hero` tem `.fhero__selo` (retângulo vermelho `#d71f3f`, `border-radius:8px`, `transform:rotate(-4deg)`, canto sup-esq). O `fiber-banner` ganhou um selo opcional equivalente (`.fbnr__selo`, settings `selo_titulo`/`selo_sub`/`selo_cor`, só renderiza se preenchido — não afeta banners sem selo). Fonte do título: `bebas-neue-pro-semiexpanded`/`Bebas Neue`/`Oswald`.

## Ligar produtos no seletor de modelo (Fly/Echoa)
Grupo de produtos ligados no seletor "mesma página" = bloco nativo `product_variations` no template do produto (metafield `custom.variacao` = rótulo do botão, lista de handles em `products`). Detalhe e mecanismo: memória `fiber-produtos-ligados-seletor-variacao`.
