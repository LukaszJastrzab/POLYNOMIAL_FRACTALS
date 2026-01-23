@echo off

set GLUT_FOLDER_NAME=./external/freeglut

IF EXIST "%GLUT_FOLDER_NAME%" (
    echo freeglut already exists...
) ELSE (
    echo downloading freeglut...
    cd external
    git clone https://github.com/freeglut/freeglut
    cd ..
)

echo Git operations done.

echo Creatring projet...
cmake -S . -B build -G "Visual Studio 16 2019" -A x64

pause
