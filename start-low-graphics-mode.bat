@echo off
pushd "%~dp0"

set QMLSCENE_DEVICE=softwarecontext
start /b bittube-wallet-gui.exe
