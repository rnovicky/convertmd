@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: convert.bat file.md
    exit /b 1
)

set "INPUT=%~1"
set "REALBASE=%~n1"
set "EXT=%~x1"
set "SCRIPTDIR=%~dp0"
set "CSSPATH=%SCRIPTDIR%convertmd.css"
REM WeasyPrint needs a proper file:/// URI with forward slashes, not a Windows path.
REM Extract drive letter, build URI generically so it works on any drive.
set "CSSDRIVE=%CSSPATH:~0,2%"
set "CSSPATHREST=%CSSPATH:~2%"
set "CSSPATHREST=%CSSPATHREST:\=/%"
set "CSSURI=file:///%CSSDRIVE%%CSSPATHREST%"

REM Build an ASCII-only temp basename to avoid cmd.exe codepage issues
REM with diacritics when paths are passed to external tools.
set "TEMPBASE=convtmp_%RANDOM%"
set "TMPMD=%TEMPBASE%%EXT%"
set "TMPHTML=%TEMPBASE%.html"
set "TMPDOCX=%TEMPBASE%.docx"
set "TMPPDF=%TEMPBASE%.pdf"

set "REALHTML=%REALBASE%.html"
set "REALDOCX=%REALBASE%.docx"
set "REALPDF=%REALBASE%.pdf"

echo Working copy: %TMPMD%
copy /y "%INPUT%" "%TMPMD%" >nul
if errorlevel 1 (
    echo ERROR: Could not create temp copy of input file.
    exit /b 1
)

echo Converting to HTML...
pandoc "%TMPMD%" -o "%TMPHTML%" --standalone --embed-resources --css "%CSSPATH%" --syntax-highlighting=pygments --metadata pagetitle="%REALBASE%" --metadata title=""
if errorlevel 1 (
    echo ERROR: HTML conversion failed.
    del /q "%TMPMD%" >nul 2>&1
    exit /b 1
)

echo Converting to DOCX...
pandoc "%TMPHTML%" -o "%TMPDOCX%" --metadata title=""
if errorlevel 1 (
    echo ERROR: DOCX conversion failed.
    del /q "%TMPMD%" "%TMPHTML%" >nul 2>&1
    exit /b 1
)

echo Converting to PDF...
pandoc "%TMPMD%" -o "%TMPPDF%" --pdf-engine=weasyprint --css "%CSSURI%" --syntax-highlighting=pygments --metadata title=""
if errorlevel 1 (
    echo ERROR: PDF conversion failed.
    del /q "%TMPMD%" "%TMPHTML%" "%TMPDOCX%" >nul 2>&1
    exit /b 1
)

REM Rename temp outputs back to the real (diacritic) filename.
move /y "%TMPHTML%" "%REALHTML%" >nul
move /y "%TMPDOCX%" "%REALDOCX%" >nul
move /y "%TMPPDF%" "%REALPDF%" >nul

del /q "%TMPMD%" >nul 2>&1

echo Done: %REALHTML%, %REALDOCX%, %REALPDF%
endlocal