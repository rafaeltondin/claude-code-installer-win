---
title: "CSS — Fibonacci System (escala, variáveis, uso)"
category: "Desenvolvimento"
tags: [css, design-system, fibonacci, espacamento, frontend, fiber]
summary: "Sistema de espaçamento/tamanho baseado em Fibonacci para todo CSS gerado — escala, variáveis e regras de uso."
secrets_required: []
last_reviewed: "2026-06-04"
---

# CSS — Fibonacci System

**Regra:** todo CSS criado deve usar a sequência de Fibonacci como base para tamanhos, margens, padding, border-radius e gaps — hierarquia visual natural em vez de palpites. **NUNCA** valores arbitrários (`1.2rem`, `0.6rem`, `13px`, `7px`) — arredondar para o Fibonacci mais próximo ou usar as variáveis.

## Escala (rem)
`0.25  0.5  0.75  1  1.5  2  3  4  6  8  12  16  24  40  64`

## Variáveis CSS
```css
--fib-1: 0.25rem;  --fib-2: 0.5rem;  --fib-3: 0.75rem;  --fib-5: 1rem;
--fib-8: 1.5rem;   --fib-13: 2rem;   --fib-21: 3rem;    --fib-34: 4rem;
```

## Uso
- **Padding** cards/containers: `--fib-8` default (`--fib-13` containers principais).
- **Gap** entre irmãos: `--fib-2` denso / `--fib-5` espaçado / `--fib-8` seções.
- **Border-radius:** `--fib-3` inputs / `--fib-5` cards / `--fib-8` modais.
- **Input/button height:** `--fib-21`.
- **Ícones/avatares:** `--fib-8` small / `--fib-13` médio / `--fib-21` large.

## Breakpoints (sempre estes)
768px (tablet), 480px (mobile), 360px (mobile pequeno).

## Font-size
`0.7rem` caption · `0.85rem` body small · `1rem` body · `1.25rem` h3 · `1.5rem` h2 · `2rem` h1.

> Práticas modernas que usam esta escala (tokens W3C, `@layer`, container queries, `clamp()`, propriedades lógicas, header/footer compartilhado): `CSS-PRATICAS-MODERNAS-TOKENS-LAYERS.md`.
