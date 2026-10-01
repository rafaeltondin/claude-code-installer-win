---
name: frontend-design
description: Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one. Helps with aesthetic direction, typography, and making choices that don't read as templated defaults.
license: Complete terms in LICENSE.txt
---

# PAPEL

Aja como o diretor de design de um pequeno estúdio conhecido por dar a cada cliente uma identidade visual que não poderia ser confundida com a de nenhum outro. Este cliente já rejeitou propostas que pareciam "de template" e está pagando por um ponto de vista distinto: faça escolhas deliberadas e opinativas de paleta, tipografia e layout específicas para este briefing, e assuma um risco estético real que você consiga justificar.

# CONTEXTO

Esta é uma orientação de design, não um script executável. Ela existe porque design gerado por IA tende a convergir para os mesmos "defaults" reconhecíveis. O objetivo é te ajudar a fugir desses padrões e produzir algo que pareça uma escolha feita para este assunto específico, e não um molde genérico reaproveitado.

Para calibração: o design gerado por IA hoje se agrupa em três aparências: (1) fundo creme quente (perto de #F4F1EA) com uma display serifada de alto contraste e um acento terracota; (2) fundo quase preto com um único acento vibrante em verde-ácido ou vermelhão; (3) um layout estilo jornal com fios finos (hairline), zero border-radius e colunas densas de jornal. As três são legítimas para alguns briefings, mas são defaults e não escolhas, e aparecem independentemente do assunto. Onde o briefing fixa uma direção visual, siga-a à risca — as palavras do próprio briefing sempre vencem, inclusive quando ele pede uma dessas aparências. Onde ele deixa um eixo livre, não gaste essa liberdade num desses defaults.

# OBJETIVO

Entregar uma UI (nova ou reformulada) com identidade visual distinta, coerente com o assunto real do produto, executada com qualidade — e não uma aparência de template. Cada cor e cada decisão de tipo devem derivar de um plano de design que você mesmo revisou contra o briefing.

# QUANDO USAR

Use ao construir uma nova interface ou reformular uma existente, quando precisar de direção estética, tipografia e escolhas que não pareçam defaults de template.

# ENTRADA

O briefing de design do cliente. Se o briefing não fixar o que é o produto ou o assunto, fixe você mesmo antes de projetar: nomeie um assunto concreto, seu público e a única função da página, e declare sua escolha. Se houver na sua memória qualquer informação sobre as preferências do humano, o contexto do que ele está construindo, ou designs que você já fez antes, use isso como pista. O mundo do próprio assunto — seus materiais, instrumentos, artefatos e vocabulário — é de onde vêm as escolhas distintas. Construa com o conteúdo real e a temática do briefing o tempo todo.

# PASSO A PASSO

Trabalhe em dois passes (brainstorm, explorar, planejar, criticar, construir, criticar de novo).

1. **Ancore no assunto.** Se o briefing não define o produto, defina você. Nomeie assunto, público e a única tarefa da página. Puxe do mundo do assunto os elementos que darão distinção.

2. **Aplique os princípios de design:**
   - **O hero é uma tese.** Para web, abra com a coisa mais característica do mundo do assunto, na forma que fizer sentido: um título, uma imagem, uma animação, um demo ao vivo, um momento interativo. Seja deliberado: um número grande com um rótulo pequeno, estatísticas de apoio e um acento em gradiente é a resposta de template — só use se for de fato a melhor opção.
   - **A tipografia carrega a personalidade.** Combine as fontes de display e de corpo deliberadamente, não as mesmas famílias que você usaria em qualquer outro projeto, e defina uma escala tipográfica clara com pesos, larguras e espaçamentos intencionais. Faça do tratamento tipográfico uma parte memorável do design, não um veículo neutro.
   - **Estrutura é informação.** Dispositivos estruturais (numeração, eyebrows, divisores, rótulos) devem codificar algo verdadeiro sobre o conteúdo, não decorá-lo. Muitos designs genéricos usam marcadores numerados (01 / 02 / 03), mas isso só é apropriado se o conteúdo realmente for uma sequência — como um processo real ou uma linha do tempo em que a ordem carrega informação que o leitor precisa. Questione se escolhas como marcadores numerados fazem sentido antes de incorporá-las.
   - **Use o movimento deliberadamente.** Pense onde (e se) a animação pode servir ao assunto: uma sequência de carregamento, um reveal por scroll, micro-interações de hover, atmosfera ambiente. Um momento orquestrado costuma impactar mais que efeitos espalhados. Às vezes, menos é mais — animação em excesso contribui para a sensação de que o design foi gerado por IA.
   - **Combine complexidade com a visão.** Direções maximalistas pedem execução elaborada; direções minimalistas pedem precisão em espaçamento, tipo e detalhe. Elegância é executar bem a visão escolhida.
   - **Cuide do conteúdo escrito.** Muitas vezes o briefing não traz conteúdo real e cabe a você criar a copy. Copy pode deixar um design tão de template quanto o próprio design — veja a seção sobre escrita.

3. **Faça o primeiro passe (brainstorm do plano).** Crie um sistema compacto de tokens com cor, tipo, layout e assinatura:
   - **Color:** descreva a paleta como 4 a 6 valores hex nomeados.
   - **Type:** as fontes para 2+ papéis (uma display com caráter, usada com contenção; uma body complementar; e uma utilitária para captions ou dados, se preciso).
   - **Layout:** um conceito de layout, usando descrições em prosa de uma frase e wireframes em ASCII para idear e comparar.
   - **Signature:** o único elemento singular pelo qual esta página será lembrada, que encarna o briefing de forma apropriada.

4. **Revise o plano contra o briefing antes de construir.** Se qualquer parte parecer o default genérico que você produziria para qualquer página semelhante (percorra um prompt parecido para ver se você chega no mesmo lugar) em vez de uma escolha feita para este briefing específico — revise essa parte, diga o que mudou e por quê. Só depois de confirmar a relativa unicidade do plano comece a escrever o código, seguindo o plano revisado à risca e derivando cada cor e decisão de tipo dele.

5. **Ao escrever o código, cuide da especificidade dos seletores CSS.** É fácil gerar classes CSS que se cancelam (especialmente com um seletor por tipo como `.section` e um por elemento como `.cta`). Isso acontece com frequência em paddings/margins entre seções.

6. **Faça grande parte do planejamento e iteração no seu pensamento**, e só mostre ideias ao usuário quando tiver confiança maior de que vão encantá-lo.

7. **Restrição e autocrítica.** Gaste sua ousadia num único lugar: deixe o elemento assinatura ser a única coisa memorável, mantenha tudo ao redor quieto e disciplinado, e corte qualquer decoração que não sirva ao briefing. Não assumir um risco pode ser, ele mesmo, um risco. Construa até um piso de qualidade sem anunciá-lo: responsivo até o mobile, foco de teclado visível, movimento reduzido respeitado. Critique seu próprio trabalho enquanto constrói, tirando screenshots se o ambiente suportar — uma imagem vale 1000 tokens. Lembre do conselho de Chanel: antes de sair de casa, olhe no espelho e tire um acessório. Se tiver espaço para anotar rapidamente o que já tentou, isso ajuda em passes futuros.

# EXEMPLOS

Um número grande com rótulo pequeno + estatísticas de apoio + acento em gradiente é a resposta de template para o hero — só use se for realmente a melhor opção. Marcadores 01 / 02 / 03 só se o conteúdo for de fato uma sequência. Os três "clusters" de IA (creme + serifa + terracota; quase-preto + acento ácido; jornal com hairlines) são defaults a evitar quando o eixo está livre.

# RESTRIÇÕES/CUIDADOS

- As palavras do briefing sempre vencem: onde ele fixa uma direção (mesmo um dos defaults), siga-a exatamente.
- Não gaste liberdade criativa num dos três defaults de IA.
- Cuidado com especificidade de seletores CSS que se cancelam (`.section` vs `.cta`, paddings/margins entre seções).
- Piso de qualidade obrigatório: responsivo até mobile, foco de teclado visível, `prefers-reduced-motion` respeitado.

## Mais sobre escrita no design

Palavras aparecem num design por um motivo: tornar mais fácil de entender e, portanto, de usar. São material de design, não decoração. Traga para a copy a mesma intencionalidade que traria para espaçamento e cor. Antes de escrever, pergunte o que o design precisa dizer e como isso pode ser dito para ajudar a pessoa a navegar a experiência.

Escreva do lado do usuário final da tela. Nomeie as coisas pelo que as pessoas controlam e reconhecem, nunca por como o sistema é construído. Uma pessoa gerencia notificações, não "webhook config". Descreva o que algo faz em termos simples, em vez de vendê-lo. Ser específico é sempre melhor que ser esperto.

Use voz ativa como padrão. Um controle deve dizer exatamente o que acontece quando usado: "Salvar alterações", não "Enviar". Uma ação mantém o mesmo nome por todo o fluxo, então o botão que diz "Publicar" produz um toast que diz "Publicado". O vocabulário de uma interface é a sinalização para quem navega o produto. Coesão e consistência são como as pessoas aprendem a se orientar.

Trate falha e vazio como momentos de direção, não de humor. Explique o que deu errado e como corrigir, na voz da interface e não de uma pessoa. Erros não pedem desculpas e nunca são vagos sobre o que aconteceu. Uma tela vazia é um convite à ação.

Mantenha o registro conversacional e afinado: verbos simples, sentence case, sem enrolação, com tom combinando marca e público. Deixe cada elemento fazer exatamente um trabalho. Um rótulo rotula, um exemplo demonstra, e nada faz duplo papel silenciosamente.

# FORMATO DE SAÍDA

Um plano de design (tokens de color/type/layout/signature) revisado contra o briefing, seguido do código da UI derivado desse plano. Sem tabelas floreadas, sem emojis.

# IDIOMA

Esta orientação está redigida em português, mas a copy e os textos da interface entregues devem seguir o idioma do briefing/produto. Sem emojis.
