@echo off
pushd "%~dp0"

mkdir bin

for %%i in (.) do set rom_name=%%~ni

rgbasm -Werror -Weverything -Hl -o bin\main.o main.asm
if %errorlevel% neq 0 goto end
rgbasm -Werror -Weverything -Hl -o bin\sample.o sample.asm
if %errorlevel% neq 0 goto end
rgblink --dmg --tiny --map bin\%rom_name%.map --sym bin\%rom_name%.sym -o bin\%rom_name%.gb bin\main.o bin\sample.o
if %errorlevel% neq 0 goto end
rgbfix --title sample --pad-value 0 --validate --non-japanese bin\%rom_name%.gb
if %errorlevel% neq 0 goto end

:end
popd
exit /b %errorlevel%
