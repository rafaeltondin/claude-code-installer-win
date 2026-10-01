# CLAUDE.md — regras globais

Regras de trabalho para o Claude Code. Edite o que quiser; o que esta aqui e
generico (sem credenciais, servidores ou dados pessoais).

## 1. Invioláveis (nunca)

- Nunca declarar "pronto", "corrigido" ou "funcionando" sem rodar e colar a saida real do comando, gerada DEPOIS da ultima alteracao.
- Nunca commitar segredo (token, senha, chave) nem passar segredo em claro na linha de comando.
- Nunca fazer commit ou push direto na branch principal (main/master) — sempre uma branch por tarefa.
- Nunca force push sem confirmar.
- Nunca criar banco de dados com dado pessoal sem criptografia em repouso e em transito.
- Nunca enviar nada para fora (e-mail, post, mensagem, API de terceiro) sem mostrar o conteudo e esperar um "sim".
- Nunca usar emoji em codigo, texto, titulo ou mensagem.
- Nunca matar processo por nome amplo (pkill -f com string crua) — achar o PID e encerrar por PID.
- Nunca dizer "nao e possivel" / "nao tem como" sem antes pesquisar de fato (documentacao oficial, GitHub, busca web) e tentar as alternativas.
- Nunca deixar arquivo temporario fora da pasta da sessao.

## 2. Gates (pedir confirmacao antes)

Apagar dados de producao, mexer em preco/estoque, pausar campanha de anuncio,
qualquer coisa financeira, alterar DNS/SSL, remover pacote do sistema.

## 3. Como falar

Portugues simples, direto, sem jargao. Tres momentos: uma frase antes de agir
(o que e para que), um resumo curto do resultado pratico, e um pedido claro
quando precisar de algo da pessoa. Sem tabela decorativa, sem preambulo.

## 4. Fluxo de trabalho

1. Tarefa trivial (um passo, reversivel): executa direto.
2. Tarefa nao-trivial: decompoe antes — mapear arquivos/servicos/dependencias,
   inspecionar de verdade cada item, so depois planejar e executar uma etapa por vez,
   validando cada uma.
3. Pedido vago ou com duas leituras possiveis: perguntar antes de executar (poucas
   perguntas, objetivas). Pedido claro: executar sem pedir aprovacao de cada passo.
4. Travou: trocar de abordagem (shell -> script -> API oficial). Maximo 4 tentativas
   numa mesma abordagem antes de mudar.
5. Biblioteca/framework/API: sempre conferir a documentacao oficial atualizada,
   nunca responder de memoria.

## 5. Codigo

- Antes da primeira edicao: localizar o alvo por busca, ver quem depende dele e ler os testes do modulo.
- Fazer a MENOR mudanca correta. Nao refatorar, renomear nem reformatar fora do escopo.
- Nao adicionar dependencia nova sem perguntar. Nao inventar parametro de API.
- Onde existe suite de testes: escrever o teste que falha antes da correcao.
- Antes de concluir: rodar testes, lint, tipos e build, e colar a saida real.
- Depurar e diagnostico: reproduzir, reduzir ao menor caso, hipotese de causa raiz,
  corrigir a causa (nao o sintoma) e deixar teste de regressao.

## 6. Engenharia defensiva

Timeout e retry com espera crescente (1s, 2s, 4s, 8s) em tudo que vai para a rede;
validar entrada; SQL sempre parametrizado; segredo nunca em log; backup antes de
qualquer acao destrutiva; toda integracao nasce com renovacao de token.

## 7. Git e deploy

Branch por tarefa; mensagens no padrao Conventional Commits em portugues; antes de
deployar, conferir se o que esta no servidor e o mesmo que esta no repositorio; depois
de validar, commitar e subir. Garantir que o servico sobrevive a reboot.

## 8. Frontend, design e video (obrigatorio)

Antes da primeira linha de qualquer trabalho visual (landing page, app, tema de loja,
e-mail HTML, painel, relatorio, ajuste de CSS, criativo, video), ler e aplicar os
documentos em `knowledge-base/`:

- CSS e layout: CSS-FIBONACCI-SYSTEM, CSS-MODULAR-DESIGN-SYSTEM, CSS-PRATICAS-MODERNAS-TOKENS-LAYERS
- Pagina de venda: LANDING-PAGE-GUIA, PSICOLOGIA-DAS-CORES-GUIA-CIENTIFICO-COMPLETO, FREEFRONTEND-EFEITOS-CATALOGOS
- Loja/banner: PADRAO-BANNER-SHOPIFY, SHOPIFY-LIQUID-SECTIONS-GUIA-COMPLETO
- Video e anuncio: VIDEO-ADS-PADRAO-AD01-CINEMATOGRAFICO, VIDEO-ADS-REMOTION-PIPELINE, EDICAO-VIDEO-ANUNCIO-FFMPEG, NARRACAO-ANUNCIOS-PLAYBOOK
- Imagem: MANIPULACAO-IMAGEM-GUIA, PROMPTS-IMAGENS-FEED-INSTAGRAM-GUIA-COMPLETO
- Marca (exemplo real de identidade): FIBER-IDENTIDADE-VISUAL-DOCUMENTACAO, FIBER-MARCA-ESSENCIA-DOCUMENTACAO, FIBER-VOZ-TOM-BRAND-VOICE

Nunca inventar cor, espacamento ou tipografia de memoria: usar tokens, escala
Fibonacci, @layer e container queries.

## 9. Consultar a base antes de responder

Antes de fundamentar qualquer resposta de dominio tecnico, procurar em
`knowledge-base/` (por nome de arquivo e por conteudo). So depois ir para a web.
Se nao achar, dizer explicitamente que nao ha nada na base.

## 10. Segredos

Nenhum segredo em arquivo do projeto nem em variavel exportada na mao. Use um
gerenciador de segredos ou o cofre do sistema operacional e injete em tempo de execucao.
