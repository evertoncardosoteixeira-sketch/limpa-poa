# LIMPA! — servidor local de teste (sem instalar nada).
# Uso: clique com o botão direito > "Executar com o PowerShell", ou no terminal:
#   powershell -ExecutionPolicy Bypass -File .\servir-local.ps1
# Abre http://localhost:3000. A câmera ao vivo exige o link https publicado (Vercel);
# aqui você testa busca, cards, Ecopontos, quiz, foto enviada da galeria e código digitado.
#   http://localhost:3000/_teste.html            → testes automáticos do app
#   http://localhost:3000/testes/gerar-clip.html → gera public/data/clip-textos.json (reconhecimento no aparelho)
param([int]$Porta = 3000)

$raiz = Join-Path $PSScriptRoot "public"
$pastaTestes = Join-Path $PSScriptRoot "testes"
$tipos = @{
  ".html"="text/html; charset=utf-8"; ".json"="application/json; charset=utf-8"; ".js"="text/javascript; charset=utf-8";
  ".css"="text/css; charset=utf-8"; ".svg"="image/svg+xml"; ".png"="image/png"; ".jpg"="image/jpeg"; ".jpeg"="image/jpeg";
  ".webp"="image/webp"; ".webmanifest"="application/manifest+json"; ".ico"="image/x-icon"
}
$http = New-Object System.Net.HttpListener
$http.Prefixes.Add("http://localhost:$Porta/")
$http.Start()
Write-Host "LIMPA! rodando em http://localhost:$Porta  (Ctrl+C para parar)"
try {
  while ($http.IsListening) {
    $ctx = $http.GetContext()
    $req = $ctx.Request; $resp = $ctx.Response; $bytes = $null
    try {
      $caminho = [Uri]::UnescapeDataString($req.Url.AbsolutePath).TrimStart("/")
      if ($caminho -eq "") { $caminho = "index.html" }

      if ($caminho -like "__log/*") {                       # mensagens das páginas de teste
        Write-Host ("LOG " + $caminho.Substring(6)); $resp.StatusCode = 204; $bytes = @()
      }
      elseif ($req.HttpMethod -eq "POST" -and $caminho -eq "__salvar/clip-textos.json") {
        $leitor = New-Object IO.StreamReader($req.InputStream, [Text.Encoding]::UTF8)
        $corpo = $leitor.ReadToEnd(); $null = $corpo | ConvertFrom-Json
        [IO.File]::WriteAllText((Join-Path $raiz "data\clip-textos.json"), $corpo, (New-Object Text.UTF8Encoding $false))
        $resp.StatusCode = 200; $bytes = [Text.Encoding]::UTF8.GetBytes('{"ok":true}')
      }
      else {
        if ($caminho -eq "_teste.html") { $arquivo = Join-Path $pastaTestes "teste-navegador.html"; $base = $pastaTestes }
        elseif ($caminho -like "testes/*") { $arquivo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot $caminho)); $base = $pastaTestes }
        else { $arquivo = [IO.Path]::GetFullPath((Join-Path $raiz $caminho)); $base = $raiz }
        if ($arquivo.StartsWith($base) -and (Test-Path $arquivo -PathType Leaf)) {
          $bytes = [IO.File]::ReadAllBytes($arquivo)
          $ext = [IO.Path]::GetExtension($arquivo).ToLower()
          $resp.ContentType = $(if ($tipos[$ext]) { $tipos[$ext] } else { "application/octet-stream" })
          $resp.StatusCode = 200
        } else {
          $bytes = [Text.Encoding]::UTF8.GetBytes('{"erro":"nao_encontrado"}')
          $resp.ContentType = "application/json"; $resp.StatusCode = 404
        }
      }
    } catch {
      $resp.StatusCode = 400; $bytes = [Text.Encoding]::UTF8.GetBytes('{"erro":"requisicao"}')
    }
    try { if ($bytes.Length) { $resp.OutputStream.Write($bytes, 0, $bytes.Length) }; $resp.Close() } catch { }
    if ($caminho -notlike "__log/*") { Write-Host ("{0} {1} {2}" -f (Get-Date -Format HH:mm:ss), $resp.StatusCode, $caminho) }
  }
} finally { $http.Stop() }
