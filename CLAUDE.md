# LIMPA! — Sua IA para educação ambiental

Projeto Limpa POA · Grupo 5 · MBA UniSenac RS (Machine Learning para Ciência de Dados).

## O que é
Web app mobile (Android primeiro) que diz onde e como descartar cada resíduo em Porto Alegre,
por texto ou foto. Orienta o uso dos serviços existentes do DMLU; não substitui a coleta nem fiscaliza.

## Estrutura
- `app/public/index.html` — interface (HTML/CSS/JS sem framework).
- `app/public/data/*.json` — cópia dos dados; a fonte de verdade fica em `.claude/skills/limpa-descarte/references/`.
- `app/server.js` — servidor e `POST /api/identificar` (foto → Claude API).
- `.claude/skills/limpa-descarte/` — regras, dados, fontes, design e prompt da foto. Use esta skill sempre.
- `PROMPT.md` — tarefa principal para o Claude Code.

## Regras do projeto
- Português do Brasil em toda a interface.
- Educar, não multar: nenhuma função de denúncia, multa ou ranking de infratores.
- Todo card cita a fonte oficial e a data de consulta; sem evidência → Fallback para a Central 156.
- Dados de descarte só de fontes oficiais (ver `references/fontes.md`). Nunca inventar endereço, horário ou regra.
- LGPD: não salvar fotos; não coletar CPF, nome, rosto ou dados de alunos; pontuação só no aparelho.
- Segredos só em `.env` (nunca no front-end, em prompts ou no git).
- Mobile first: testar em 412 px (Pixel 7), sem rolagem horizontal, temas claro e escuro.

## Estrutura atual (substitui a seção acima)
- `public/index.html` (app), `public/data/*.json`, `api/identificar.mjs` (foto → Claude, Vercel Functions),
  `vercel.json`. Foto: código/QR na foto → Claude (se ANTHROPIC_API_KEY na Vercel) → MobileCLIP no aparelho
  (`public/data/clip-textos.json`, gerado por `testes/gerar-clip.html` a partir de `testes/clip-prompts.json`).
  Mascote Limpinho: função `limpinho(pose)` no index.html (poses: cabeca, ola, identificar, dicas, conquistar, pensando, foto, orientar). Código de barras: Open Food Facts → partes da embalagem → itens da base. Ver README.md.

## Comandos
- `powershell -ExecutionPolicy Bypass -File .\servir-local.ps1` — servidor local em http://localhost:3000
- http://localhost:3000/_teste.html — testes de navegador (busca, Fallback, abas, código de barras)
- `node --test testes/` — testes da validação da API (precisa de Node 20+)
- `.\sync-data.ps1` — copia os JSON da skill para `public/data/`
