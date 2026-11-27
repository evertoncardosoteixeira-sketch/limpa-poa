# Copia a fonte de verdade (skill limpa-descarte) para os dados do app.
# Rode sempre que alterar residuos.json ou ecopontos.json na skill.
$ref = Join-Path $PSScriptRoot ".claude\skills\limpa-descarte\references"
$dst = Join-Path $PSScriptRoot "public\data"
foreach ($f in "residuos.json", "ecopontos.json") {
  $conteudo = Get-Content (Join-Path $ref $f) -Raw -Encoding UTF8
  $null = $conteudo | ConvertFrom-Json   # falha aqui se o JSON estiver quebrado
  Copy-Item (Join-Path $ref $f) (Join-Path $dst $f) -Force
  Write-Host "ok  $f"
}
