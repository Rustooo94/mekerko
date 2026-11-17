# Rindërton demo/app.html nga index.html (me të dhëna fiktive nga demo/mock.js).
# Ekzekutoni pas çdo ndryshimi të index.html:  powershell -ExecutionPolicy Bypass -File demo\build.ps1
$root = Split-Path -Parent $PSScriptRoot
$u = New-Object Text.UTF8Encoding $false
$t = [IO.File]::ReadAllText((Join-Path $root 'index.html'), $u)
$t = $t.Replace('<script src="config.js"></script>', '<script src="mock.js"></script>')
$t = $t.Replace('src="login.html"', 'src="../login.html"')
$t = $t.Replace('<title>', '<meta name="robots" content="noindex"><title>Demo · ')
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'app.html'), $t, $u)
"demo/app.html u rindërtua."
