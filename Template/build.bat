@echo off

mkdir bin
rgbasm -Werror -Weverything -Hl -o bin\main.o main.asm
rgbasm -Werror -Weverything -Hl -o bin\sample.o sample.asm
rgblink --dmg --tiny -map bin\sample.map --sym bin\sample.sym -o bin\sample.gb bin\main.o bin\sample.o
rgbfix --title sample --pad-value 0 --validate --non-japanese bin\sample.gb
