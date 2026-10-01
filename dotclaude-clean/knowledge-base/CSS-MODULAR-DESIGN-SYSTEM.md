---
title: "CSS — Arquitetura Modular / Design System (estrutura, tokens, convenções)"
category: "Desenvolvimento"
tags: [css, design-system, modular, tokens, frontend, fibonacci, responsivo, dark-mode]
topic: "Como estruturar o CSS de qualquer projeto de forma modular e padronizada"
priority: high
version: "1.0.0"
last_updated: "2026-06-13"
secrets_required: []
summary: "Receita de CSS modular do jeito que o Rafael gosta (moderno/minimalista/didático): pasta styles/ com partials por camada, índice só de @import, tokens semânticos, escala Fibonacci em px, breakpoints 768/480/360, dark-mode/densidade via [data-*]. Complementa CSS-FIBONACCI-SYSTEM.md (escala) com a ARQUITETURA dos arquivos."
---

# CSS — Arquitetura Modular / Design System

> Complementa `CSS-FIBONACCI-SYSTEM.md`: aquele define a **escala de espaçamento**;
> este define **como organizar os arquivos** de CSS de um projeto. Referência viva:
> o painel **lojasaas/Atracou** (`admin/src/styles/`, 20 módulos, ~2050 linhas, build Vite).
> Técnicas modernas (tokens W3C, `@layer`, container queries, `clamp()`, propriedades
> lógicas, header/footer compartilhado): `CSS-PRATICAS-MODERNAS-TOKENS-LAYERS.md`.

## Princípio
CSS de projeto (painel, app, landing não-trivial) **nunca** é um arquivo monolítico.
É um **design system modular**: vários partials de responsabilidade única, juntados por
um índice de `@import`. O bundler (Vite/PostCSS/esbuild) inlina os `@import` em build →
**um CSS único, hasheado e cacheado** (sem custo por requisição). Editar fica trivial
(acha-se o módulo certo na hora) e o visual fica padronizado e previsível.

## Estrutura de pastas (padrão)
```
src/styles.css            ← ÍNDICE: só @import, na ordem do cascade
src/styles/
  _tokens.css             ← variáveis (cores, escala Fibonacci, sombras, tempos, z-index)
  _theme-modes.css        ← dark-mode (opt-in) + densidade, redefinindo só tokens
  _base.css               ← reset + elementos HTML + acessibilidade (focus-visible, scrollbar)
  _layout.css             ← shell, sidebar, topo, conteúdo
  _layout-primitives.css  ← stack / cluster / grid-auto / ratio (tijolos de composição)
  _buttons.css            ← botões (variantes, tamanhos, estados)
  _forms.css              ← inputs, selects, checkbox, switch, validação
  _cards.css              ← cartões, seções, notas
  _tables.css             ← tabelas (scroll-x no mobile via :has)
  _feedback.css           ← badges, alertas, vazio, skeleton, modal, animações (@keyframes)
  _auth.css / _dashboard.css / _appearance.css  ← telas específicas
  _navigation.css         ← tabs, breadcrumb, paginação, steps, segmented
  _data.css               ← progress, timeline, kv-list, totals
  _commerce.css           ← preço, estoque, chips de variação, thumb-grid, order-flow (se e-commerce)
  _motion.css             ← animações de entrada + microinterações reutilizáveis
  _misc.css               ← dropzone, stepper, tag-input, swatches, kbd
  _utilities.css          ← classes utilitárias (Fibonacci) — vêm DEPOIS dos componentes
  _responsive.css         ← breakpoints 768/480/360 + @media print — SEMPRE por último
```
> Nem todo projeto precisa de todos. Mínimo viável: `_tokens + _base + _layout +
> _buttons + _forms + _cards + _feedback + _utilities + _responsive`.

## Ordem do cascade (no índice)
`tokens → theme-modes → base → layout(+primitives) → componentes → telas → utilitários → responsivo`.
Utilitários depois dos componentes (vencem por especificidade igual + ordem); responsivo por
último (sobrescreve tudo nos breakpoints). O `styles.css` deve conter **só** `@import` (a spec
CSS exige `@import` antes de qualquer regra).

```css
/* src/styles.css */
@import './styles/_tokens.css';
@import './styles/_theme-modes.css';
@import './styles/_base.css';
@import './styles/_layout.css';
/* … componentes … */
@import './styles/_utilities.css';
@import './styles/_responsive.css';
```
No entrypoint JS (ex. `main.jsx`): `import './styles.css';` (um só).

## Tokens semânticos (o coração)
Componentes **nunca** usam valor cru nem cor literal — consomem **aliases semânticos**.
Trocar tema/marca = mudar um escopo, não caçar regra.

```css
:root{
  /* escala Fibonacci (ver CSS-FIBONACCI-SYSTEM.md) */
  --fib-1:1px; --fib-2:2px; --fib-3:3px; --fib-5:5px; --fib-8:8px; --fib-13:13px;
  --fib-21:21px; --fib-34:34px; --fib-55:55px; --fib-89:89px; --fib-144:144px;
  --fib-233:233px; --fib-377:377px; --fib-610:610px; --fib-987:987px;
  /* paleta crua → aliases semânticos */
  --ink:#111827; --muted:#6b7280; --line:#e5e7eb; --bg:#f8fafc; --surface:#fff; --brand:#4f46e5;
  /* derivados: raios, sombras (blur Fibonacci), tempos, z-index nomeados */
  --r-sm:var(--fib-5); --r-md:var(--fib-8); --r-lg:var(--fib-13);
  --shadow-sm:0 var(--fib-1) var(--fib-3) rgba(17,24,39,.06);
  --t-fast:89ms; --t-base:144ms; --ease:cubic-bezier(.4,0,.2,1);
}
```
Dark-mode/densidade redefinem só os tokens, num escopo — **zero mudança nos componentes**:
```css
[data-theme="dark"]{ --bg:#0b0f1a; --surface:#151b29; --ink:#f4f6fa; --line:#2a3548; }
[data-density="compact"]{ --control-h:var(--fib-21); }  /* + ajustes finos */
```
Dark-mode é **opt-in** (`<html data-theme="dark">`), NÃO `prefers-color-scheme` automático
(senão muda o visual de quem já está no claro sem pedir).

## Regras inegociáveis
1. **Nada de valor cru.** Espaço/raio/gap/sombra saem da escala Fibonacci. Se o projeto já
   usa Fibonacci em **px literais** (3,5,8,13,21,34,55,89,144,233,377,610,987), mantenha px —
   **não** troque pela escala rem da KB no meio do caminho (muda o significado de cada var e
   quebra o layout existente). Projeto novo: escolha uma convenção e seja consistente.
2. **Preservar classes ao editar projeto existente.** É *enhancement*, não *rewrite*: porte
   TODA classe que o HTML/JSX já usa (`.card/.btn/.badge/...`) para os módulos novos, redefinindo
   com polimento. Quebrou uma classe = quebrou a tela.
3. **Autoexplicativo.** Cada módulo abre com um comentário dizendo o quê/porquê. Componentes
   ganham comentário curto. (O "didático" que o Rafael pede.)
4. **Acessibilidade no `_base`:** `:focus-visible` com anel, `prefers-reduced-motion`, `.sr-only`.
5. **Responsivo nos breakpoints do projeto:** 768 (tablet) / 480 (mobile) / 360 (mobile pequeno)
   + `@media print` quando houver recibo/pedido. Mobile-first nos componentes; o `_responsive`
   só ajusta. Ex.: sidebar vira nav horizontal rolável no mobile (sem JS).
6. **Tabela responsiva sem mexer no JSX:** `.card:has(> table){ overflow-x:auto }` (`:has` é
   suportado no Edge/Chrome atuais — já usado no projeto).

## Estética alvo (o que o Rafael gosta)
Moderno, **minimalista**, fácil de usar, autoexplicativo. Sombras suaves (blur Fibonacci),
cantos arredondados, transições rápidas (89–233ms), paleta neutra + 1 cor de marca, foco
visível, hierarquia tipográfica clara. Sem excesso de profundidade/gradiente.

## Gotchas aprendidos
- **`@import` de CSS local** é resolvido e inlinado pelo Vite/PostCSS em build (não é o `@import`
  runtime lento). Filenames com `_` prefix e `.css` explícito funcionam.
- **Build = lint.** esbuild/Vite **rejeita CSS sintaticamente inválido** no build — se buildou, a
  sintaxe está ok. Mas build OK ≠ visual OK: confira no navegador.
- **Não é gotcha de CSS, mas casa:** em componente React, `useState`/hooks **sempre antes** de
  qualquer `return` condicional — hook após early-return = "rendered more hooks" = tela em branco
  (incidente Appearance.jsx ao adicionar upload). Validar a página após mexer.
- CSS não usado (componentes do kit ainda não usados pelo JSX) é aceitável: é uma **biblioteca**
  pronta pras próximas telas, não só estilo das atuais. Gzip cobre o peso.

## Checklist ao gerar/editar CSS de projeto
- [ ] Pasta `styles/` com partials por camada + índice só de `@import` na ordem do cascade.
- [ ] `_tokens` com escala Fibonacci + aliases semânticos; componentes só consomem tokens.
- [ ] Classes existentes preservadas (se projeto já existe).
- [ ] `_base` com focus-visible + reduced-motion.
- [ ] `_responsive` 768/480/360 (+ print) por último.
- [ ] Comentário de cabeçalho em cada módulo.
- [ ] Buildou limpo + conferido no navegador (1 tela por categoria: auth, lista, dashboard).

## REGRA OBRIGATÓRIA — controles na mesma linha, mesma altura

Campo (input/select) e botão que aparecem LADO A LADO (calculadora de frete, busca,
newsletter, cupom, filtro) têm que ter EXATAMENTE a mesma altura. Nunca definir
altura separada em cada um — declarar UMA variável no container e aplicar nos dois,
com `box-sizing: border-box` (senão a borda do input soma e desalinha) e
`align-items: stretch` no container.

```css
.bloco {
  --controle-altura: 46px;
}

.bloco__form {
  display: grid;                                /* campo elástico + botão fixo */
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 8px;
  align-items: stretch;
}

.bloco__input,
.bloco__botao {
  height: var(--controle-altura);
  min-height: var(--controle-altura);
  max-height: var(--controle-altura);
  box-sizing: border-box;
  line-height: normal;                          /* line-height:1 encolhe o botão */
}
```

Cuidados que já causaram bug real (Sul Etiquetas, ago/2026):
- Não reaproveitar classe utilitária de tema sem ler o que ela faz: no tema Cenora
  a classe `.input` é o INVÓLUCRO do campo, não o campo — usá-la esmagou o input e
  esticou o botão pela linha inteira.
- Botão em linha não pode ter `width: 100%` herdado do tema: fixar `width: auto` +
  `min-width`, e só no celular virar largura total.
