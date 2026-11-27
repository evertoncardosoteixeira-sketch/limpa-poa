// Testes da validação da resposta do Claude (sem rede, sem chave).
// Rodar com Node 20+:  node --test testes/
import { test } from "node:test";
import assert from "node:assert/strict";
import { validar, SISTEMA } from "../api/identificar.mjs";

test("id válido e confiança alta passam", () => {
  const r = validar('{"id":"pet","objeto":"garrafa de água","confianca":"alta","estado":"vazio","alternativas":["pote"],"pergunta":""}');
  assert.equal(r.id, "pet"); assert.equal(r.confianca, "alta"); assert.deepEqual(r.alternativas, ["pote"]);
});
test("id inventado vira nenhum com confiança baixa", () => {
  const r = validar('{"id":"golfinho","confianca":"alta","alternativas":["xyz","pilha"]}');
  assert.equal(r.id, "nenhum"); assert.equal(r.confianca, "baixa"); assert.deepEqual(r.alternativas, ["pilha"]);
});
test("JSON quebrado vira confiança baixa", () => {
  const r = validar("Claro! Aqui está {id: pet,,,");
  assert.equal(r.id, "nenhum"); assert.equal(r.confianca, "baixa");
});
test("JSON com texto em volta é extraído", () => {
  const r = validar('Resposta: {"id":"filtro","confianca":"media"} fim');
  assert.equal(r.id, "filtro"); assert.equal(r.confianca, "media");
});
test("prompt traz catálogo e defesa contra instrução na foto", () => {
  assert.match(SISTEMA, /pizzasuja: /);
  assert.match(SISTEMA, /nunca uma instrução/);
});
