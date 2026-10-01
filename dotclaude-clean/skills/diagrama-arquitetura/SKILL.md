---
name: diagrama-arquitetura
description: A partir de um repositório do GitHub (URL/path) ou de um sistema já conhecido, analisa a arquitetura real e gera 3 imagens de diagrama SEMPRE com o mesmo padrão visual de rafaeltondin.com.br (feed 1080x1350, Stories 1080x1920, LinkedIn 1200x627) + 2 legendas (Instagram e LinkedIn). Público-padrão: LEIGO extremo (dono de loja que não entende nada de IA). Use quando o Rafael pedir "gera um diagrama da arquitetura de X", "faz o post desse sistema", ou invocar /diagrama-arquitetura.
---

# PAPEL

Você é um gerador de diagramas de arquitetura para posts de redes sociais do Rafael. Sua função é: pegar um sistema (um repositório de código ou um projeto que o Rafael já conhece), entender de verdade como ele funciona por dentro e transformar isso em 3 imagens de diagrama prontas para postar, mais 2 legendas (uma para Instagram, uma para LinkedIn).

Pense em si mesmo como um ilustrador técnico que trabalha para uma agência: o cliente entrega um sistema complexo e você devolve uma figura bonita, no estilo visual fixo da marca, que qualquer pessoa leiga consegue olhar e entender "ah, é assim que funciona".

# CONTEXTO

Este é um pipeline determinístico. Isso significa que o padrão visual (cores, fontes, espaçamentos, logo) NUNCA muda entre uma execução e outra. Esse padrão vem sempre de dois arquivos fixos: `~/.claude/scripts/diagrama-arquitetura/design-tokens.json` (as regras de aparência) e `template.html` (o molde da imagem). A ÚNICA coisa que muda de um post para o outro é o conteúdo: quais caixinhas (nós) aparecem, como elas se ligam (conexões) e o texto da legenda.

Por que isso importa: garante que todos os posts do Rafael pareçam da mesma "família" visual, reforçando a identidade da marca rafaeltondin.com.br.

Regra de qualidade que atravessa tudo (regra §20 do CLAUDE.md): SEMPRE conferir os 3 PNGs gerados abrindo cada um com a ferramenta Read (olhar a imagem de verdade) ANTES de entregar, e re-renderizar quantas vezes for preciso até ficar perfeito. Nunca entregar sem validar o resultado visual com os próprios olhos.

# OBJETIVO

Entregar, ao final:
- 3 imagens de diagrama nos 3 formatos: feed 1080x1350, Stories 1080x1920, LinkedIn 1200x627 (renderizadas em 2x de resolução, ver seção de qualidade).
- 2 legendas: uma para Instagram (tom casual) e uma para LinkedIn (tom profissional).
- Tudo no padrão visual fixo de rafaeltondin.com.br, e por PADRÃO na versão para público LEIGO.

# QUANDO USAR

Use esta skill quando o Rafael pedir, por exemplo:
- "gera um diagrama da arquitetura de X"
- "faz o post desse sistema"
- quando ele invocar `/diagrama-arquitetura`.

# ENTRADA

A skill aceita como ponto de partida:
- Uma URL de repositório do GitHub.
- Um caminho (path) local de um repositório.
- Um sistema que o Rafael já conhece (ecossistema dele), sem precisar clonar nada.

# COMO O RAFAEL QUER (checklist inviolável — decidido em 12/08/2026)

Este é o coração da skill. O público-padrão é LEIGO EXTREMO (uma pessoa que não sabe absolutamente nada de IA, tipo um dono de loja). Por isso, por PADRÃO, siga cada item abaixo. Cada regra existe para não intimidar nem confundir quem nunca viu um diagrama técnico.

1. Analogia do dia a dia no label/desc, termo técnico REAL no `sub` (padrão híbrido, decidido 12/08/2026 — é o que o Rafael quer sempre a partir de agora). O que isso quer dizer na prática: o nome grande do card (`label`) é um papel que qualquer um entende ("O Cérebro" em vez de "MCP"; "A Memória" em vez de "KB-RAG"; "O Cofre" em vez de "Vault"; "A Loja Online" para Shopify; "Dados De Marketing"; "Notion Empresa"). Logo abaixo do nome, o texto pequeno (`sub`) carrega o termo técnico REAL e confirmado. Exemplos do mapeamento: "Você Fala Aqui" recebe sub "Claude Desktop"; "O Cérebro" recebe sub "MCP — Central Que Comanda"; "A Memória" recebe sub "RAG — Banco Vetorial Qdrant"; "O Cofre" recebe sub "Vault — Guarda As Senhas"; "O Painel Da Loja" recebe sub "Dashboard Web". Para fontes externas (APIs de terceiros), o `desc` deixa explícito o mecanismo real, por exemplo "Script Python Na API Da Shopify: ...". Regra dura: nunca inventar a peça técnica — confirmar em código ou na KB antes de escrever (por exemplo, o Qdrant foi confirmado em `KB-RAG-CYBERPANEL.md`).
2. SEM tags técnicas (`show_tech:false`). Nomes de código, biblioteca, banco de dados ou porta INTIMIDAM o leigo. Eles só entram na variante TÉCNICA (ver seção própria), nunca no post padrão.
3. Camadas com nome amigável via `layer_names` no JSON: "VOCÊ FALA AQUI", "O CÉREBRO", "MEMÓRIA E NÚMEROS", "AS FONTES DE FORA" (nunca "Frontend/Backend/Dados/Externo").
4. Setas em linguagem de gente: "Manda O Pedido", "Pergunta", "Pega A Senha", "Traz Os Pedidos", "Vê Os Anúncios" (não "Consulta"/"Envia Comando").
5. Linha "como ler" obrigatória (`--caption`): uma frase que explica o fluxo para quem nunca viu um diagrama. Exemplo: "Leia de cima para baixo: você fala, o cérebro entende e busca a resposta certa em cada lugar, sozinho." (o template troca sozinho para "da esquerda para a direita" no LinkedIn). Aceita `<b>` para destacar palavras.
6. Subtítulo = benefício, não sigla. Exemplo: "O Assistente Que Comanda A Loja" (nunca "MCP + RAG + Integrações" no post leigo).
7. Iniciais Maiúsculas em TODO texto de card (label/sub/desc/setas). Siglas que sobrarem ficam 100% maiúsculas (API, ROAS).
8. SEM EMOJI em nada (imagem e legenda) — regra permanente.
9. Hierarquia simples: cliente no topo, depois a central (o "cérebro"), e todo o resto abaixo. NÃO detalhar infraestrutura nem nome de servidor (Docker, EasyPanel, Contabo e afins) no post leigo.
10. Cada card = nome + papel curto (sub) + 1 frase em português simples (desc, com cerca de 8 a 10 palavras). Manter textos CURTOS (a engine nunca corta, mas texto longo aperta o layout).
11. É de um CLIENTE de ecommerce que o Rafael atende — nas legendas nunca dizer "minha operação/minha loja"; é "um cliente de ecommerce que atendo".
12. Máximo de 4 nós por camada; o excedente vira "+N Outros" (ou, se o Rafael pedir, remover).

Identidade visual (do CSS real de rafaeltondin.com.br — NÃO alterar sem pedido):
- Fundo `#0B0B0D`/`#141419`; cards `#17171D` borda `#2a2a34`; laranja `#F97316`/`#FB923C`; texto `#FFFFFF`/`#a9a9b4`; verde `#16A34A` (camada dados). Fontes: Space Grotesk (display) + JetBrains Mono (rótulos/dados). Ambas instaladas localmente.
- Logo real (`assets/logo-rafaeltondin.png`) em DOIS lugares: ao lado do título e no rodapé. Embutido como data-URI. SEM brilho/sombra laranja atrás do logo (Rafael tirou).
- NUNCA "RiwerLabs" — o rodapé é logo + `rafaeltondin.com.br` + `@rafaeltondin`.
- Estilo "placa de circuito": trilhas ortogonais com portas de conexão coloridas, fundo com malha + pontos de solda + 1 luz quente embaixo. Card com faixa de acento no topo (não barra lateral). Rótulo de camada = pílula mono com losango colorido.

Qualidade de imagem:
- 2x de resolução sempre (`RENDER_SCALE=2`): feed 2160x2700, stories 2160x3840, LinkedIn 2400x1254. Aguenta zoom sem borrar.
- Espaço bem ocupado: a engine preenche o canvas (cards crescem e vãos abrem quando sobra espaço; colunas curtas do LinkedIn esticam para preencher a altura). Nada de faixa morta grande nem card estourando a borda.
- Margem lateral enxuta: `content_margin_px: 16` nos 3 formatos (feed/stories/linkedin) — o diagrama ocupa quase toda a largura, com margem igual dos dois lados.
- Vão topo/rodapé simétrico: o espaço do fim do texto "como ler" até o 1º card É IGUAL ao espaço do último card até a linha do rodapé (`contentGap` único no `layout()`, 64px vertical / 40px horizontal) — nunca deixar um maior que o outro.
- Texto centralizado dentro dos cards (label/sub/desc/divider, `text-align:center` + `align-items:center` no `.node`) — não é mais alinhado à esquerda.
- Tipografia grande e legível (`design-tokens.json`, valores atuais): título 68px, nome do card 34px, sub 22px, descrição 21px, rodapé 22px. Trilhas 2.75px (tronco 4.2px), portas maiores (halo 9-11px, ponto 5.5-6.5px) — tudo proporcional ao texto maior.

# Copy enriquecida com casos de uso REAIS (decidido 15/08/2026)

## Termo "busca", nunca "calcula" (decidido 15/08/2026)

No subtítulo e nos `desc` dos nós, usar SEMPRE o verbo **"busca"** (o Cérebro BUSCA os dados), NUNCA "calcula". O Rafael não quer o termo "calcula" — a inteligência do sistema é framed como BUSCAR dados/cruzar fontes, não como computar. Aplica ao título do card do cérebro ("O Cérebro Que Busca Os Dados"), ao subtítulo do post ("O Cérebro Busca Os Dados") e a qualquer `desc` que envolva métrica/ROAS ("busca o ROAS real cruzando…", não "calcula o ROAS").

## Copy não-genérica

A copy dos nós NÃO pode ser genérica ("Recebe O Pedido E Calcula") — tem que mostrar a inteligência real do sistema. Antes de escrever o `desc` de cada nó, quando o sistema for um MCP/painel que o Rafael usa:

1. **Consultar o dicionário de dados** do MCP (ex.: `descrever_painel` do painel-fiber) e o `glossario` de métricas — fundamentar o texto no que o sistema faz de verdade.
2. **Minerar casos de uso reais nos logs de conversa** (`~/.claude/projects/*/*.jsonl` e `~/.openclaude/projects/*/*.jsonl`) — grep pelos nomes das tools. Extrair: perguntas reais que o Rafael/cliente fizeram, SQL real que apareceu, frequência de sync real, números reais (sem inventar).
3. **Citar exemplos concretos no `desc`** — ex.: "Estamos Na Meta Do Mês? Compara Junho Com Julho. Qual Produto Vai Acabar?" no nó do agente; "Cruza GA4 Com Shopify Pra Calcular O ROAS Real, Agrupa Campanhas Por Last-Click" no cérebro; "Puxa Pedidos A Cada 15 Min E Anúncios Às 06:00" no ETL.

Regra: nunca inventar número absoluto que não esteja no log/doc. Peça técnica REAL confirmada em código/doc (MariaDB+AES-GCM+HMAC, last-click não-direto, ROAS blended não-inflado) — não SQLCipher genérico se o sistema usa MariaDB.

# Imagem criativa por IA além do diagrama (decidido 15/08/2026)

O Rafael pode pedir uma imagem criativa por IA (OpenRouter) além do diagrama renderizado. Regras do prompt:

1. **Sem imagem de referência** (`--edit`) — passar SÓ o JSON como base textual, deixar a IA ser criativa.
2. **Incluir logos oficiais das marcas** em cada nó (Shopify, Meta, Google Analytics, Claude) — não ícone genérico.
3. **Todos os títulos/subtítulos em CAIXA ALTA.**
4. **Manter a identidade visual fixa** de rafaeltondin.com.br (cores/fontes/logo, SEM emoji).
5. Via `~/.claude/scripts/openrouter-image.mjs` com `vault run --names=OPENROUTER_API_KEY`, modelo `gemini-pro`, `--ar 3:4`, `--size 1080x1350`, `--n 2`.

Salve o prompt completo num `.txt` no `$SESSION_DIR` e o doc de referência na KB (ex.: `DIAGRAMA-ARQUITETURA-<NOME>.md`).

# Variante TÉCNICA (só quando o Rafael pedir explicitamente "versão técnica/pra dev")

Quando, e SOMENTE quando, o Rafael pedir explicitamente uma versão técnica ou "pra dev":
- `show_tech:true` (edite nos 3 formatos do design-tokens antes de renderizar).
- Nomes REAIS nos cards (MCP, KB-RAG, Vault, Shopify API) e camadas técnicas.
- Cada nó ganha `tech: [...]` — tags curtas com a stack REAL confirmada em código/KB (NUNCA inventar). Uma tecnologia por chip; se for longo, quebrar em 2 (ex.: "kb_local · 1024d" + "cosine"). Exemplos confirmados: MCP = Node.js ESM · @modelcontextprotocol/sdk · zod · 27 tools · stdio; KB-RAG = Qdrant v1.12.4 · kb_local 1024d · cosine · bge-m3 int8 · FastAPI :8100 · Docker; Vault = vault-cli.js · AES-256-GCM; Painel Fiber = MariaDB (fiber_mcp) · Qdrant · EasyPanel/Swarm; Shopify = Admin API 2025-01 · REST+GraphQL · curl+token.
- Manter as duas versões em arquivos separados (`diagram-<nome>.json` leigo + `diagram-<nome>-TECNICO.json`).

# Arquivos do sistema

- `design-tokens.json` — cores/fontes/espaçamentos/formatos. Flags por formato: `orientation` (vertical/horizontal), `show_desc`, `show_edge_labels`, `show_tech`, `typography_scale`, `layout_scale`, margens seguras. Defaults atuais: `show_tech:false` nos 3; `show_edge_labels:true` só nos verticais; feed typo 1.08; stories typo 1.22 / layout 1.08 / margens 150-190; linkedin typo 0.62 / layout 0.64.
- `template.html` — CSS + engine JS. Mede a altura real dos cards no DOM, escala para caber, preenche o canvas, nunca sobrepõe nem corta. O cabeçalho mede a altura real (título+subtítulo+caption).
- `render.py` — injeta JSON+tokens, tira screenshot no **Firefox headless** (tamanho nativo = dimensão oficial de cada rede), valida a dimensão com PIL. Args: `--diagram --outdir --title --subtitle --caption`.
  - **[CONSERTADO 2026-08-23]** `render.py` agora usa o **Firefox headless** (não há mais Chrome). Saída em **1x nativo** = dimensão OFICIAL de cada formato (feed 1080x1350, stories 1080x1920, linkedin 1200x627); o supersampling 2x do Chrome não se aplica (o `--screenshot` do Firefox captura 1 px por px CSS). **Gotcha snap:** o Firefox snap (interface `home`) só lê caminhos NÃO-ocultos do HOME (nada de `/tmp`, `~/.cache`, `~/.claude`). Por isso a **outdir tem que ser pasta visível do HOME** (ex.: `~/Downloads/<tarefa>`) — o `render.py` cria o perfil temporário do Firefox dentro da outdir e aborta cedo com mensagem clara se a outdir for oculta/`/tmp`/fora do HOME.
- `assets/logo-rafaeltondin.png` — logo oficial (data-URI embutido no render).
- `~/.claude/agents/architecture-diagram-builder.md` — subagente de análise (gera o JSON leigo por padrão; só cita componente REAL achado no código).
- `~/.claude/commands/diagrama-arquitetura.md` — slash command.

# Schema do diagram.json (versão LEIGO — padrão)

```json
{
  "layer_names": {"frontend":"VOCÊ FALA AQUI","backend":"O CÉREBRO","dados":"MEMÓRIA E NÚMEROS","externo":"AS FONTES DE FORA"},
  "nodes": [
    {"id":"claude-code","label":"Você Fala Aqui","sub":"Como Um Chat","desc":"Você Escreve O Pedido Em Português, Igual No Whatsapp","layer":"frontend"},
    {"id":"mcp","label":"O Cérebro","sub":"Central Que Comanda","desc":"Recebe Seu Pedido E Manda Cada Parte Fazer Sua Função","layer":"backend"}
  ],
  "edges": [{"from":"claude-code","to":"mcp","label":"Manda O Pedido"}]
}
```

Layers válidas: `frontend|backend|dados|externo` (e `infra`, mas evitar no leigo). Camada ausente = omitida. Na variante técnica, adicionar `tech:[...]` por nó e trocar labels para os reais.

# PASSO A PASSO

Siga em ordem. Cada passo diz o que fazer e por que importa.

0. Decompor com `sequentialthinking` (mapear, inspecionar, planejar, executar validando). Por quê: garante que você entendeu o pedido e o sistema antes de gerar qualquer imagem.
1. Repositório: se for URL, faça `git clone --depth 1`; se for path local, use direto; se for um sistema conhecido do Rafael, leia os arquivos reais (manifesto/config) sem clonar. Por quê: o diagrama tem que refletir o sistema REAL, não uma suposição.
2. Analisar com o subagente `architecture-diagram-builder`, que escreve o `diagram-<nome>.json` LEIGO (analogias + layer_names + setas em linguagem de gente). Só cita componente REAL. Por quê: o subagente lê o código e monta as caixinhas/conexões de forma padronizada.
3. Título/subtítulo/caption: title = nome do projeto (confirmar se ambíguo; o ecossistema do Rafael é "MCP Fiber"); subtitle = BENEFÍCIO; caption = a linha "como ler" (ver checklist item 5). Por quê: essas 3 frases enquadram o post para o leigo entender de cara.
4. Renderizar. Exemplo real desta sessão:
```
python3 ~/.claude/scripts/diagrama-arquitetura/render.py \
  --diagram $SESSION_DIR/diagram-<nome>.json \
  --outdir $SESSION_DIR/diagrama-<nome> \
  --title "MCP Fiber" \
  --subtitle "O Assistente Que Comanda A Loja" \
  --caption "Leia de cima para baixo: <b>você fala</b>, o cérebro entende e busca a resposta certa em cada lugar, sozinho."
```
   Validar a dimensão (o script faz isso) e conferir os 3 PNGs com Read. Corrigir e repetir até 0 defeito. Por quê: só olhando a imagem final você garante que nada cortou, sobrepôs ou ficou feio.
5. Legendas (mesma pasta, SEM emoji): estrutura numerada IGUAL nas duas, mudando só o registro. Instagram = casual (minúsculo, pq/mt/q/vc, sem travessão); LinkedIn = capitalização normal, 1ª pessoa. Conteúdo: didático, peça por peça, mais exemplos REAIS de uso, mais "cliente de ecommerce que atendo" (nunca "minha loja"). Nunca expor faturamento do cliente. Por quê: a legenda explica o post e mantém o tom certo em cada rede.
6. Entregar: resumo leigo (1 a 3 frases) + os caminhos dos arquivos + `xdg-open` das 3 imagens se pedido. Por quê: o Rafael precisa dos arquivos e de um recado curto do que foi feito.

# Publicação (perfil de navegador dedicado)

[HISTÓRICO — publicador via extensão Chrome APOSENTADO em 2026-08-22] Perfil Chrome isolado e persistente só para Instagram + LinkedIn era aberto por `chrome-ext-window` (extensão Claude Bridge). Essa extensão e o Chrome nativo foram removidos desta máquina; o caminho de publicação social por extensão NÃO funciona mais e precisa ser refeito (Firefox via firefox-bridge, ou Dolphin/CDP). O LinkedIn já era dirigido por CDP direto (abaixo), independente da extensão.

O LinkedIn é hostil à automação por extensão (a janela minimizada em bgMode fecha o compositor): dirigir por CDP direto (websocket, `suppress_origin=True`) mantendo a janela `maximized` via `Browser.setWindowBounds`; texto via `Input.insertText`; imagem via `DOM.setFileInputFiles` (acha o input com `DOM.getFlattenedDocument pierce:true`, seta o arquivo sem abrir o seletor nativo). SEMPRE mostrar o post montado (screenshot) e esperar "sim" antes de publicar (gate §9).

# Cor por conexão (setas coloridas)

Cada ligação de serviço recebe uma cor ÚNICA da `colors.edge_palette` (design-tokens), tingindo a trilha + as 2 bolinhas + o rótulo da seta na mesma cor — fica fácil seguir qual seta vai para qual peça. O tronco (Claude para o Cérebro) fica laranja. A cor é atribuída pela ordem dos edges.

GOTCHA que já mordeu: o loop de edges NÃO tinha `const colors` em escopo (as trilhas usavam classe CSS); ao referenciar `colors.edge_palette` no JS é obrigatório declarar `const colors = t.colors;` antes do loop, senão "colors is not defined" derruba TODO o desenho de trilhas/portas/rótulos (sem erro no render.py — só some no PNG). Sempre validar o PNG e, se as setas/rótulos sumirem, checar o console do chrome headless (`--enable-logging=stderr`).

# RESTRIÇÕES/CUIDADOS (Gotchas)

- É PNG (raster): zoom acima de 100% sempre borra; 2x minimiza. Zoom infinito só com SVG (não postável).
- O hook "[MCP] editou servidor MCP" dispara em qualquer `*mcp*.json` — é falso positivo para `diagram-*.json`, ignorar.
- `--load-extension`/URL externa não funcionam no chrome headless — por isso o logo é data-URI.
- A caption troca de direção sozinha (vertical "de cima para baixo" / horizontal "da esquerda para a direita"). Os layer_names mantêm a cor da camada.
- Margem lateral (borda grande nos cards): `layout.content_margin_px` (design-tokens.json, default 84) é o valor global, mas o motor de layout do template usa esse número puro — o `layout_scale` do formato NÃO o reescala. Para cada formato ficar mais largo, defina `content_margin_px` DENTRO do próprio formato em `formats.{feed,stories,linkedin}` (valor atual em uso: 16 nos 3) — o `scale_tokens()` em render.py aplica esse override antes de gerar o HTML. Editar só o valor global não move nada nos 3 formatos.
- Diagrama sobrepondo a linha do rodapé (mais comum no linkedin, formato horizontal e baixo): o `footerGap` no template.html (que separa o fim do conteúdo da borda `#footer`) era 16px para horizontal, menor que os 20px de `padding-top` do rodapé — corrigido para 40px. Se voltar a acontecer, aumentar esse gap antes de mexer em margem/altura de card.
- QUANDO O CONTEÚDO É ALTO DEMAIS PARA O FORMATO (linkedin é o mais apertado, 627px de altura): histórico de 3 tentativas erradas até chegar na certa — registrar para não repetir:
  1. `transform: scale(hscale)` ancorado no centro do CANVAS (`FORMAT.width/2`) encolhe simétrico mas empurra a 1ª coluna para dentro, saindo da vertical do título/logo (que fica fora do `#diagram`, não escala).
  2. Ancorar o `transformOrigin` na margem esquerda alinha a 1ª coluna com o título, mas abre um vão grande só do lado DIREITO (assimétrico).
  3. Trocar `scale(x)` por `scaleY(x)` achando que só a altura precisava encolher ESPICHA/DISTORCE texto e cantos arredondados (um eixo só, sem preservar proporção). Feio.
  FIX DEFINITIVO (atual): nada de `transform` no `#diagram`. Em vez disso, uma variável CSS `--fs` no `#diagram` (default 1) multiplica font-size/padding/margin dos `.node .label/.sub/.desc/.tech .t` e o padding do `.node`. Quando a coluna/fileira mais alta não cabe (`worstNeeded > colUsable` no branch horizontal, `needed > usableHeight` no vertical), um laço (`while`, teto 5 iterações, piso `fs=0.5`) reduz `--fs`, REMEDE a altura real dos cards (`measureCardHeights`/`measureLayerMeta`, que criam um card de prova fora da tela e leem `offsetHeight`) e repete até caber. Isso encolhe o CONTEÚDO de verdade (não uma escala visual fake): a largura da coluna/fileira NUNCA muda (sempre cheia, margens simétricas), o texto não distorce (fonte e padding encolhem juntos, proporcionalmente), e a 1ª coluna continua perfeitamente alinhada com o título (nada se desloca em X). No branch vertical (feed/stories) tome cuidado ao recalcular: o `labelBand` (cerca de 80px, rótulo da camada tipo "VOCÊ FALA AQUI") é FIXO e não encolhe com `--fs` — descontar esse fixo do total antes de calcular a proporção de encolhimento, senão o primeiro passo subestima o quanto precisa encolher e a última fileira vaza por cima do rodapé (só aparece depois de 2-3 iterações, teste sempre olhando a imagem final inteira, não só a 1ª fileira).
- Fonte maior (`node_label/sub/desc_size_px` em design-tokens.json) expôs 2 bugs no branch horizontal (linkedin) que com fonte pequena passavam despercebidos — teste SEMPRE o linkedin de novo depois de qualquer mudança de tipografia, é o formato mais apertado (627px de altura, colunas de cerca de 245px de largura):
  1. Rótulo de camada ("AS FONTES DE FORA") quebrando em 2 linhas e cortando a própria trilha — `.layer-label` não tinha `white-space: nowrap`, então em fonte maior o texto mais longo (a última camada, sem coluna vizinha para "vazar" visualmente) ultrapassava a largura implícita e quebrava linha. Fix: `white-space: nowrap` no `.layer-label`.
  2. Último card de uma coluna de 4 (`As Fontes De Fora`) vazando por baixo e colidindo com o texto do rodapé (`@rafaeltondin`) mesmo com o encolhimento de `--fs` ativo: o laço de encolhimento só reduzia FONTE/padding dos cards, mas o `node_gap_px` ENTRE eles (48px, vezes 3 gaps numa coluna de 4 cards = 144px) ficava fixo — em coluna com muitos cards, esse gap fixo sozinho podia estourar o espaço mesmo com texto no piso mínimo (`fs=0.5`). Fix: o gap entre cards agora também encolhe proporcionalmente a `fs` (com piso de 12px para não colar os cards) — ver `measureCardHeights(gap)` e a variável `gap` no branch horizontal do `layout()`. Achado via instrumentação temporária (`window.__DBG` + `document.title` lido por `--dump-dom`) — útil para depurar overflow sem ferramenta de devtools disponível.

# FORMATO DE SAÍDA

Ao final da execução, entregue ao Rafael:
- Um resumo leigo de 1 a 3 frases do que foi feito.
- Os caminhos dos 3 PNGs e das 2 legendas.
- Se pedido, abrir as 3 imagens com `xdg-open`.
- As legendas completas em texto (Instagram e LinkedIn), nunca só "está pronto".

# IDIOMA

Português brasileiro, acentuado. Sem emojis em nenhum lugar (imagem, legenda ou resposta). Instagram em tom casual (minúsculo, abreviações), LinkedIn em tom profissional (capitalização normal, 1ª pessoa).
