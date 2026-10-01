---
title: "Fiber — Filtros de coleção: Benefício (tags), Cor (bolinhas) e Tamanho"
tags: [fiber, shopify, prestige, filtros, search-discovery, tema]
updated: 2026-09-17
summary: "Como a coluna de filtros das coleções da Fiber funciona (Prestige 8.3.0, tema 162265759961): Benefício por tags beneficio:* renderizado no tema (sem app), Cor via Search & Discovery (estava escondida), Tamanho via S&D. Gotchas: S&D não tem API; collection.all_tags vem vazio (usar collection.tags); calcados-1 é redirect."
---

# Contexto
Loja fiber-knit-sport-br (www.fiberoficial.com.br), tema Prestige 8.3.0 id 162265759961. Feito em 2026-09-17 a pedido do Rafael: filtro por categoria, cor com bolinhas e tamanho em toda coleção.

# Como ficou
- Ordem na sidebar (snippets/facets.liquid): Benefício, Tamanho, Cor, Preço. Mesma coisa no drawer mobile.
- **Benefício** = bloco custom no facets.liquid, ANTES do loop `results.filters`. Lê `collection.tags` com prefixo `beneficio:` e gera links `/collections/<handle>/tag1+tag2` (filtro nativo de tag, AND) preservando `filter.v.*` ativos e `sort_by`. Links usam `is="facet-link"` (AJAX do Prestige). Item ativo = link que remove a tag.
- Tags: `beneficio:Conforto casual`, `beneficio:Leveza e performance`, `beneficio:Recuperação muscular`, `beneficio:Compressão e suporte`, `beneficio:Aderência e grip` (83 produtos). Produto novo: basta adicionar a tag — aparece sozinho no filtro da coleção onde ele está.
- (2026-09-17 à noite) Cor e Tamanho RETIRADOS da sidebar a pedido do Rafael: no navegador o clique não respondia; por curl o servidor filtrava certo. Causa no JS não investigada (sem Firefox controlável). Linha de `continue` no loop results.filters.
- **Cor** = filtro do app Search & Discovery (já estava ligado). O facets.liquid tinha uma linha `{% if filter.param_name == 'filter.v.option.cor' or color_label_list contains _dc_label %}{% continue %}` que ESCONDIA o filtro — removida. Bolinha vem de `settings.color_swatch_config` (nome:#hex ou nome:imagem.jpg); nomes novos precisam de entrada lá (19 adicionadas).
- Valores de cor dos produtos padronizados (125 renomes via productOptionUpdate/optionValuesToUpdate): Black/PRETO/Preta->Preto, Gray/Grey->Cinza, White/Branca->Branco, Marinho/Deep Blue/Azul Oxford->Azul Marinho, Lilac/Clear Purple->Lilás, All Purpura->Vinho, Soft Pink->Rosa Claro, Branco/Branco mantido (variante distinta). Mapa: ~/Downloads/filtros-colecao-fiber (mapa-cores.py na sessão) e cores-renomeadas-2026-09-17.json.

# Gotchas (causa -> fix -> prevenção)
1. Search & Discovery NÃO tem API (Admin/Storefront) pra criar/ligar filtros — confirmado por introspecção do schema 2025-07 (nenhuma mutation filter/discovery) e fóruns. Fix: filtro por tag no tema. Prevenção: pra filtro novo por atributo, ou usa tag no tema ou Rafael liga no app manualmente.
2. `collection.all_tags` retornou vazio (size 0) na Fiber; `collection.tags` funciona (tags dos produtos da visão atual). Usar `collection.tags`.
3. `/collections/calcados-1` é REDIRECT antigo pra `calcados`; com path de tag (`/calcados-1/tag`) retorna 0 produtos. Testar sempre no handle real (collections.json).
4. Propagação de themeFilesUpsert no storefront leva 10-25s — validar com sleep >= 20s senão parece que não aplicou.
5. Renomear valor de opção: dois valores do mesmo produto não podem virar o mesmo nome (colisão) — simular antes (ex.: Lilac × All Purpura na Sapatilha Training).
6. Escrita de tema via themeFilesUpsert NÃO foi bloqueada nesta sessão (memória antiga dizia que precisava `!` do Rafael).

# Mobile: Benefício não filtrava (2026-09-29, tema 166850035929)
Dois problemas somados (só no celular):
1. **Pop-up do Fiber Club cobria a gaveta.** `#fiber-popup-overlay` (assets/fiber-popup.css) tem `z-index:999999`; a gaveta de filtros (`facets-drawer`) é `z-index:999`. O pop-up ficava por cima e bloqueava o toque justo na área do Benefício (1º filtro, no topo) — Cor/Tamanho ficam mais embaixo, fora da imagem do pop-up, por isso "só o Benefício" falhava. Sinal confiável: quando um drawer abre, o `<html>` ganha a classe `.lock` (o pop-up sozinho NÃO adiciona `.lock`). Fix em `fiber-popup.css`: `html.lock #fiber-popup-overlay{opacity:0!important;visibility:hidden!important;pointer-events:none!important}` (esconde o pop-up enquanto qualquer gaveta está aberta; volta ao fechar).
2. **`<a is="facet-link">` não filtra dentro do `facets-drawer`.** O custom element `FacetLink` (assets/theme.js, click→AJAX) foi feito pra sidebar do desktop; dentro da gaveta o clique não faz nada (a gaveta aplica filtros de FORM ao FECHAR, via `dialog:after-hide`→submit do `facets-form`, e o link de tag não é campo de form). Fix no bloco Benefício do `facets.liquid`: um `<script>` que, DENTRO de `facets-drawer`, troca o `<a is="facet-link">` por `<a>` comum (`replaceWith` + `MutationObserver` p/ sobreviver ao re-render) — clique navega direto pra `/collections/<handle>/<tag>` (que filtra server-side; o mesmo URL que o desktop atinge). Desktop intacto (a sidebar não está em `facets-drawer`).

Validação: Playwright mobile 390 + desktop 1440, coleção calcados, 348→66. Backups em `~/Downloads/sabe-sessao-sobre-lancamento-echoa-pulse/backup-kb-hooks/` (fiber-popup.ANTES.css, facets.ANTES.liquid).

# Reverter
`bash ~/Downloads/filtros-colecao-fiber/aplicar-tema.sh reverter` (grava facets.liquid + settings_data.json originais). Tags/cores: JSON "antes" em backup-2026-09-17/catalogo-tags-opcoes-antes.json.

# Tamanho religado (2026-09-30, tema 167127285977)
A pedido da equipe, o `continue` do facets.liquid agora pula só `filter.v.option.cor`; Tamanho voltou. Testado com Playwright (Chromium headless): desktop 1440 marcar "40" em calcados -> URL `?filter.v.option.tamanho=40`, 16->13 produtos; celular 390 pela gaveta -> "Filtrar (1)" e grade filtrada. O "clique não respondia" de 17/09 não se reproduziu (provavelmente era o pop-up do Fiber Club cobrindo a gaveta, corrigido em 29/09). Pendência estética: os números infantis (18/19...) aparecem antes dos adultos (ordem vem do S&D).
