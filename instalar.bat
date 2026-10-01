@echo off
setlocal enabledelayedexpansion
title Instalador Claude Code

REM ============================================================
REM  Este arquivo roda em DUAS fases:
REM   fase A (--deps) : Chocolatey/Node/Git -> precisa ADMIN
REM   fase B (normal) : Claude Code + PATH + config       -> precisa ser o
REM                     SEU usuario (nunca o do administrador), senao o
REM                     claude e instalado no perfil errado e o comando
REM                     "claude" nao e encontrado depois.
REM  Por isso: NAO use "Executar como administrador". De 2 cliques normais.
REM ============================================================

if /i "%~1"=="--deps" goto deps

net session >nul 2>&1
if %errorlevel% equ 0 (
    echo ============================================
    echo  ATENCAO
    echo ============================================
    echo Esta janela esta como ADMINISTRADOR.
    echo Feche e abra o instalar.bat com 2 cliques normais ^(sem "Executar como administrador"^).
    echo Motivo: o Claude Code precisa ser instalado no SEU usuario. Como administrador
    echo ele vai para outra pasta e o comando "claude" nao funciona no seu terminal.
    echo.
    pause
    exit /b 1
)

echo ============================================
echo  Instalador: Claude Code + dependencias
echo ============================================
echo.
echo Usuario desta instalacao: %USERNAME%
echo.

REM ---------- fase A: dependencias, em janela elevada ----------
echo [1/4] Instalando dependencias ^(Chocolatey, Node.js, Git^)...
echo        O Windows vai pedir permissao de administrador. Clique em Sim.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = Start-Process -FilePath '%~f0' -ArgumentList '--deps' -Verb RunAs -Wait -PassThru; exit $p.ExitCode"
if !errorlevel! neq 0 (
    echo [ERRO] As dependencias nao foram instaladas. Veja a mensagem da janela de administrador.
    pause
    exit /b 1
)

REM PATH desta janela: node/git recem-instalados ainda nao aparecem sozinhos
set "PATH=%ProgramFiles%\nodejs;%ProgramFiles%\Git\cmd;%ALLUSERSPROFILE%\chocolatey\bin;%USERPROFILE%\.local\bin;%APPDATA%\npm;%PATH%"

where node >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERRO] Node.js nao foi encontrado mesmo depois da instalacao.
    echo Reinicie o computador e rode este instalador de novo.
    pause
    exit /b 1
)

REM ---------- fase B: Claude Code (instalador nativo oficial) ----------
echo.
echo [2/4] Instalando o Claude Code...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol=3072; try { $s = Invoke-RestMethod -UseBasicParsing https://claude.ai/install.ps1; & ([scriptblock]::Create($s)) } catch { Write-Host ('FALHA: ' + $_.Exception.Message); exit 1 }"
set "NATIVO=!errorlevel!"

set "CLAUDE_EXE="
if exist "%USERPROFILE%\.local\bin\claude.exe" set "CLAUDE_EXE=%USERPROFILE%\.local\bin\claude.exe"
if not defined CLAUDE_EXE if exist "%LOCALAPPDATA%\Programs\claude\claude.exe" set "CLAUDE_EXE=%LOCALAPPDATA%\Programs\claude\claude.exe"

if not defined CLAUDE_EXE (
    echo [AVISO] O instalador oficial nao deixou o claude no lugar esperado. Tentando pelo npm...
    call npm install -g @anthropic-ai/claude-code
    if exist "%APPDATA%\npm\claude.cmd" set "CLAUDE_EXE=%APPDATA%\npm\claude.cmd"
)

if not defined CLAUDE_EXE (
    echo [ERRO] Nao consegui instalar o Claude Code ^(codigo do instalador oficial: !NATIVO!^).
    echo Abra o PowerShell como SEU usuario e rode: irm https://claude.ai/install.ps1 ^| iex
    pause
    exit /b 1
)
echo        Encontrado em: !CLAUDE_EXE!

REM ---------- PATH permanente do usuario (a causa do "claude nao e reconhecido") ----------
echo.
echo [3/4] Deixando o comando "claude" disponivel em qualquer terminal...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$alvos = @((Join-Path $env:USERPROFILE '.local\bin'), (Join-Path $env:APPDATA 'npm')) | Where-Object { Test-Path $_ }; $atual = [Environment]::GetEnvironmentVariable('Path','User'); if (-not $atual) { $atual = '' }; $novo = $atual; foreach ($a in $alvos) { $tem = ($novo -split ';' | Where-Object { $_.TrimEnd('\') -ieq $a.TrimEnd('\') }); if (-not $tem) { $novo = ($novo.TrimEnd(';') + ';' + $a).TrimStart(';'); Write-Host ('adicionado ao PATH: ' + $a) } else { Write-Host ('ja estava no PATH: ' + $a) } }; if ($novo -ne $atual) { [Environment]::SetEnvironmentVariable('Path', $novo, 'User') }"

REM ---------- configuracao limpa ----------
echo.
echo [4/4] Aplicando configuracao padrao...
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
xcopy /E /I /Y "%~dp0dotclaude-clean\*" "%USERPROFILE%\.claude\" >nul

REM ---------- verificacao real ----------
echo.
echo Conferindo se o Claude Code responde...
"!CLAUDE_EXE!" --version
if !errorlevel! neq 0 (
    echo [AVISO] O Claude foi instalado, mas nao respondeu ao teste de versao.
    echo Reinicie o computador e tente rodar: claude
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Instalacao concluida e testada.
echo  FECHE este terminal, abra um NOVO e rode: claude
echo  ^(na primeira vez ele pede login na sua conta Anthropic^)
echo  Se o novo terminal ainda disser que nao conhece "claude",
echo  reinicie o computador uma vez.
echo ============================================
pause
exit /b 0

REM ============================================================
:deps
REM fase A - roda elevada
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Esta fase precisa de administrador.
    pause
    exit /b 1
)

where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo Instalando Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol=3072; try { iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) } catch { Write-Host ('FALHA: ' + $_.Exception.Message); exit 1 }"
    if !errorlevel! neq 0 (
        echo [ERRO] Falha instalando Chocolatey.
        pause
        exit /b 1
    )
) else (
    echo Chocolatey ja instalado.
)
set "PATH=%ALLUSERSPROFILE%\chocolatey\bin;%PATH%"

call :instala node    nodejs-lts        "Node.js LTS"     || exit /b 1
call :instala git     git               "Git"             || exit /b 1
echo Dependencias prontas.
exit /b 0

:instala
where %1 >nul 2>&1
if %errorlevel% equ 0 (
    echo %~3 ja instalado.
    exit /b 0
)
echo Instalando %~3...
choco install %2 -y --no-progress
set "RC=!errorlevel!"
if !RC! equ 0 exit /b 0
if !RC! equ 3010 exit /b 0
echo [ERRO] Falha instalando %~3 ^(codigo !RC!^).
pause
exit /b 1
