@echo off
setlocal enabledelayedexpansion
title Instalador Claude Code + LibreOffice

echo ============================================
echo  Instalador: Claude Code + dependencias + LibreOffice
echo ============================================
echo.

REM precisa rodar como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Rode este arquivo como ADMINISTRADOR ^(botao direito - Executar como administrador^).
    pause
    exit /b 1
)

REM 1) Chocolatey (gerenciador de pacotes Windows)
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo [1/5] Instalando Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if !errorlevel! neq 0 (
        echo [ERRO] Falha instalando Chocolatey. Abortando.
        pause
        exit /b 1
    )
) else (
    echo [1/5] Chocolatey ja instalado, pulando.
)
REM garante o choco no PATH desta janela (logo apos instalar ele ainda nao esta)
set "PATH=%ALLUSERSPROFILE%\chocolatey\bin;%PATH%"

REM 2) Node.js LTS (necessario pro Claude Code)
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [2/5] Instalando Node.js LTS...
    choco install nodejs-lts -y
    if !errorlevel! neq 0 if !errorlevel! neq 3010 (
        echo [ERRO] Falha instalando Node.js LTS. Abortando.
        pause
        exit /b 1
    )
) else (
    echo [2/5] Node.js ja instalado, pulando.
)

REM 3) Git
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [3/5] Instalando Git...
    choco install git -y
    if !errorlevel! neq 0 if !errorlevel! neq 3010 (
        echo [ERRO] Falha instalando Git. Abortando.
        pause
        exit /b 1
    )
) else (
    echo [3/5] Git ja instalado, pulando.
)

REM 4) LibreOffice
where soffice >nul 2>&1
if %errorlevel% neq 0 (
    echo [4/5] Instalando LibreOffice...
    choco install libreoffice-fresh -y
    if !errorlevel! neq 0 if !errorlevel! neq 3010 (
        echo [AVISO] Falha instalando LibreOffice. Seguindo com o Claude Code.
    )
) else (
    echo [4/5] LibreOffice ja instalado, pulando.
)

REM recarrega PATH desta sessao pra achar node/npm recem-instalados
if exist "%ALLUSERSPROFILE%\chocolatey\bin\refreshenv.cmd" call "%ALLUSERSPROFILE%\chocolatey\bin\refreshenv.cmd" >nul 2>&1
set "PATH=%ProgramFiles%\nodejs;%ProgramFiles%\Git\cmd;%USERPROFILE%\.local\bin;%PATH%"

REM 5) Claude Code - instalador nativo oficial (metodo atual recomendado pela Anthropic;
REM     npm install -g @anthropic-ai/claude-code esta descontinuado)
echo [5/5] Instalando Claude Code (instalador nativo oficial)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; irm https://claude.ai/install.ps1 | iex"
if !errorlevel! neq 0 (
    echo [ERRO] Falha no instalador nativo do Claude Code.
    echo Rode manualmente no PowerShell: irm https://claude.ai/install.ps1 ^| iex
    pause
    exit /b 1
)

REM copia a configuracao limpa (sem dados pessoais) para %USERPROFILE%\.claude
echo Aplicando configuracao padrao...
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
xcopy /E /I /Y "%~dp0dotclaude-clean\*" "%USERPROFILE%\.claude\" >nul

echo.
echo ============================================
echo  Instalacao concluida.
echo  Abra um novo terminal e rode: claude
echo  (na primeira vez ele vai pedir login na sua conta Anthropic)
echo ============================================
pause
