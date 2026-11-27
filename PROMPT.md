# Prompt para o Claude Code — LIMPA! Sua IA para educação ambiental

> Como usar: abra esta pasta no VS Code, inicie o Claude Code no terminal (`claude`) e cole o bloco abaixo.
> Ou rode direto: `claude "$(cat PROMPT.md)"`.

---

Use a skill `limpa-descarte` (em `.claude/skills/limpa-descarte`) e leia o `CLAUDE.md` antes de começar.

## Contexto
O LIMPA! é o web app do Projeto Limpa POA (Grupo 5, MBA UniSenac RS): o cidadão digita ou fotografa um
resíduo e o app mostra a lixeira certa (cores CONAMA 275), como preparar, o fluxo de Porto Alegre
(Coleta Seletiva, orgânico/rejeito, ponto especial ou Ecoponto/156), os Ecopontos com horário e mapa,
um rascunho para a Central 156 e um quiz com pontuação. Princípio: educar, não multar.

O ponto de partida é `app/public/index.html`, uma página única que hoje roda como artefato do Claude.
Lá, o reconhecimento por foto usa `window.claude.use("sample")`, que **não existe fora do Claude**.

## Objetivo
Transformar a página num app que rode localmente e possa ser hospedado, mantendo o visual e o conteúdo,
com o reconhecimento por foto funcionando via API do Claude no servidor.

## Tarefas
1. **Estrutura**
   - Projeto Node 20+ com Express (ou Vite + uma API serverless, se preferir; explique a escolha).
   - `app/server.js` serve `app/public/` e expõe `POST /api/identificar`.
   - `app/public/data/residuos.json` e `ecopontos.json` copiados de `.claude/skills/limpa-descarte/references/`
     (crie um script `npm run sync-data` que copia de lá).
   - `.env.example` com `ANTHROPIC_API_KEY=` e `MODELO_FOTO=claude-haiku-5-5`; `.env` no `.gitignore`.
2. **Separar dados do código**: no `index.html`, troque os arrays `ITEMS` e `ECO` embutidos por `fetch` dos JSON.
   Mostre um estado de carregamento e uma mensagem de erro amigável se o JSON não carregar.
3. **Foto fora do Claude**:
   - Substitua o uso de `claude.use("sample")` por: redimensionar a imagem no navegador (máx. 1024 px, JPEG 0,8),
     enviar como `multipart/form-data` para `/api/identificar`.
   - No servidor, siga exatamente `references/prompt-foto.md` (prompt, JSON de resposta, validação do id).
   - Use o SDK oficial `@anthropic-ai/sdk`. Chave só no servidor. Timeout de 15 s. Limite 5 MB.
   - Não salve a foto; log só com id, confiança, latência e tokens.
   - Rate limit simples por IP (ex.: 10 fotos/min) para evitar abuso de custo.
   - Mantenha o botão de câmera na barra de busca e o botão grande "Tirar ou enviar foto do resíduo"
     (`<input type="file" accept="image/*" capture="environment">`).
4. **Remover o que é exclusivo do artefato**: o meta `claude:viewport-fit-sides` e qualquer `window.claude`.
   Adicione `<!doctype html>`, `lang="pt-BR"`, meta viewport e `manifest.webmanifest` + ícone para
   "Adicionar à tela inicial" no Android (PWA simples, sem service worker por enquanto).
5. **Testes**
   - Playwright no emulador Pixel 7: carrega sem erro no console, sem rolagem horizontal, busca "sofa",
     "oleo", "pizza suja", item inexistente cai no Fallback 156, troca de abas por hash.
   - Teste da API com a chamada ao Claude mockada: id inválido vira `nenhum`; JSON quebrado vira confiança baixa.
   - Um teste manual descrito no README com as fotos da tabela de `prompt-foto.md`.
6. **README.md** em português: como instalar, configurar a chave, rodar (`npm run dev`), testar no celular
   pela mesma rede Wi-Fi (`http://<ip-do-pc>:3000`), e como publicar (Render, Railway ou Vercel).

## Regras
- Siga os guardrails da skill (sem multa/denúncia, fonte em todo card, Fallback 156, LGPD, sem dados de alunos).
- Não invente regras de descarte, endereços ou horários. Se precisar de dado novo, pare e me pergunte
  ou marque como `TODO: validar com DMLU`.
- Preserve o visual (veja `references/design.md`) e o texto em português do Brasil.
- Trabalhe em etapas, mostre o plano antes de começar e rode os testes ao final de cada etapa.
- Não faça commit nem push sem eu pedir.

## Entrega esperada
- `npm install && npm run dev` abre o LIMPA! em `http://localhost:3000`.
- Foto de uma garrafa de água no celular → card "Garrafa PET", lixeira vermelha, Coleta Seletiva.
- Resumo final: o que mudou, como testar e o que ficou pendente.
