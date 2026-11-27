# LIMPA! — servidor local de teste (sem instalar nada).
# Uso: clique com o botão direito > "Executar com o PowerShell", ou no terminal:
#   powershell -ExecutionPolicy Bypass -File .\servir-local.ps1
# Abre http://localhost:3000. A foto por IA e a câmera ao vivo exigem o link https publicado
# (Vercel); aqui você testa busca, cards, Ecopontos, quiz e código de barras digitado.
param([int]$Porta = 3000)

$raiz = Join-Path $PSScriptRoot "public"
$tipos = @{
  ".html"="text/html; charset=utf-8"; ".json"="application/json; charset=utf-8"; ".js"="text/javascript; charset=utf-8";
  ".css"="text/css; charset=utf-8"; ".svg"="image/svg+xml"; ".png"="image/png"; ".jpg"="image/jpeg";
  ".webmanifest"="application/manifest+json"; ".ico"="image/x-icon"
}
$http = New-Object System.Net.HttpListener
$http.Prefixes.Add("http://localhost:$Porta/")
$http.Start()
Write-Host "LIMPA! rodando em http://localhost:$Porta  (Ctrl+C para parar)"
try {
  while ($http.IsListening) {
    $ctx = $http.GetContext()
    $caminho = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart("/")
    if ($caminho -eq "") { $caminho = "index.html" }
    # Página de testes automáticos: http://localhost:3000/_teste.html (fica fora de public/, não é publicada)
    if ($caminho -eq "_teste.html") { $arquivo = Join-Path $PSScriptRoot "testes\teste-navegador.html" }
    else { try { $arquivo = [IO.Path]::GetFullPath((Join-Path $raiz $caminho)) } catch { $arquivo = "" } }
    $resp = $ctx.Response
    if (($arquivo.StartsWith($raiz) -or $caminho -eq "_teste.html") -and (Test-Path $arquivo -PathType Leaf)) {
      $bytes = [IO.File]::ReadAllBytes($arquivo)
      $ext = [IO.Path]::GetExtension($arquivo).ToLower()
      $resp.ContentType = $(if ($tipos[$ext]) { $tipos[$ext] } else { "application/octet-stream" })
      $resp.StatusCode = 200
    } else {
      $bytes = [Text.Encoding]::UTF8.GetBytes('{"erro":"nao_encontrado"}')
      $resp.ContentType = "application/json"; $resp.StatusCode = 404
    }
    try { $resp.OutputStream.Write($bytes, 0, $bytes.Length); $resp.Close() } catch { }  # navegador fechou a conexão
    Write-Host ("{0} {1} {2}" -f (Get-Date -Format HH:mm:ss), $resp.StatusCode, $caminho)
  }
} finally { $http.Stop() }
