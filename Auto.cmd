@echo off
set ServerName=server0
set validate=false
set ServerDirectory=C:\Rust_Servers\server\
set ManagedDirectory=C:\Rust_Servers\server\RustDedicated_Data\Managed\
set SteamCMD=C:\Rust_Servers\steamcmd\
set scripts=C:\Rust_Servers\scripts\
set downloads=C:\Rust_Servers\downloads\
set wgetDirectory=C:\Program Files (x86)\GnuWin32\bin\
set 7zDirectory=C:\Program Files\7-Zip\
set curl=C:\Rust_Servers\scripts\curl\bin\
set appid=252490
set steamkey=https://steamcommunity.com/dev/apikey

cls
echo.
echo *************************************************************
echo *                     Rust Auto Update                      *
echo *                      By: Tiny_420's                       *
echo *************************************************************
echo.

:update_check

cd %curl%
rem curl call to get the latest game server version from the steam servers
start /wait curl.exe -o %scripts%%ServerName%-latest-version.txt ""http://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?key=%steamkey%^&appid=%appid%^&format=json"" >nul && echo [DBUG] SteamAPI Passed! || [DBUG] SteamAPI FAILED!
cd %scripts%
if exist %ServerName%-current-version.txt (
rem echo file exist so do nothing and perform file check to compare existing files
echo "" >nul
) else (
rem echo file doesn't exist so create it and update / install the game server to the latest version
COPY %ServerName%-latest-version.txt %ServerName%-current-version.txt >nul && echo [DBUG] %ServerName%-current-version.txt has been updated.

echo.
echo file doesn't exist, starting update! - %date%,%time%
echo.

goto run_update
)
rem file check compare the latest game server version with the current and if they match or miss match
fc /b %ServerName%-latest-version.txt %ServerName%-current-version.txt >nul
if errorlevel 1 (
    COPY %ServerName%-latest-version.txt %ServerName%-current-version.txt >nul && echo [DBUG] %ServerName%-current-version.txt has been updated.
    del %ServerName%-latest-version.txt
    echo.
    echo Server out of date, starting update... %date%,%time%
    echo.
	echo goto run_update
) else (
    del %ServerName%-latest-version.txt
    echo.
    echo No update, Server Starting... %date%,%time%
    echo.
	goto Start_Server 
)

:run_update
cls
color 3
echo.
echo *************************************************************
echo *                     Rust Auto Update                      *
echo *                      By: Tiny_420's                       *
echo *************************************************************
echo.

cd %scripts%
::Start update Prossess

::Game Update
cd %SteamCMD%
if %validate% == true (
echo.
echo Rust uptateing-validate equals %validate%! - %date%,%time%
echo.
call steamcmd.exe +login anonymous +force_install_dir %ServerDirectory% +app_update 258550 validate +quit
set validate="false"
) else (
call steamcmd.exe +login anonymous +force_install_dir %ServerDirectory% +app_update 258550 +quit
echo.
echo Rust uptateing-validate equals %validate%! - %date%,%time%
echo.
)

::update oxide
cd %wgetDirectory%
wget.exe --no-verbose --no-check-certificate https://umod.org/games/rust/download -O "%downloads%Oxide.Rust.zip"
echo.
echo Oxide Downloaded! - %date%,%time%
echo.

::extract
cd "C:\Program Files\7-Zip" 
7z.exe x -spe "%downloads%Oxide.Rust.zip" -o"%ServerDirectory%" -aoa

del %downloads%Oxide.Rust.zip

echo.
echo Oxide extracted! - %date%,%time%
echo.

::update discord ext
cd %wgetDirectory%
wget.exe --no-verbose --no-check-certificate https://umod.org/extensions/discord/download -O "%ManagedDirectory%Oxide.Ext.Discord.dll"
echo.
echo Oxide.Ext.Discord.dll downloaded - %date%,%time%
echo.
cd %scripts%

echo.
echo Last update - %time% %date% >%ServerName%-LOG.txt
echo.

COPY %ServerName%-latest-version.txt %ServerName%-current-version.txt >nul && echo [DBUG] %ServerName%-current-version.txt has been updated.
::Done Updating.
timeout /t 2 /nobreak
goto Start_Server

:Start_Server
cls
color 3
echo.
echo *************************************************************
echo *                       Tiny_420's                          *
echo *                Rust auto update script                    *
echo *************************************************************
echo.

echo.
echo Starting %ServerName% - %date%,%time%
echo.

cd %ServerDirectory%

::Start Server
title "%ServerName% Started @ %time% - %date%"
start /WAIT /HIGH RustDedicated.exe -batchmode -nographics -silent-crashes -logfile "log.txt" +server.ip 0.0.0.0 +server.port 28015 +rcon.ip 0.0.0.0 +rcon.port 28016 +rcon.password Letmein +server.tickrate 30 +server.level "Procedural Map" +server.seed 6712 +server.worldsize 4000 +server.maxplayers 50  +server.hostname "[US] ANTI-V3N0M 5X [MODDED]" +server.description "Server Auto Update By:Tiny_420" +server.url "https://antiv3n0m.com" +server.headerimage "" +server.identity "server0" +rcon.web 1

::Server Stoped/Crashed Going to update_check
echo.
echo %ServerName% stopped - %date%,%time%
echo.
echo restarting in..
timeout /t 5 /nobreak
cd %scripts%
goto update_check

if errorlevel 1 goto error 

:error
cls
echo.
echo *************************************************************
echo *                     Rust Auto Update                      *
echo *                      By: Tiny_420's                       *
echo *************************************************************
echo.

echo.
echo [ERROR] Will update in..
timeout /t 60 /nobreak
echo.
set validate="true"
goto run_update