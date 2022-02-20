@echo off
setlocal enabledelayedexpansion

:: А-05-19 Ушаков Н.А. ЛР-1
:: Вариант 24. Перевод из 2-8 в 2-10 сс
echo Converter: bin-oct to bin-dec...

rem Исходное число
set /p binoctNum=Enter a number in bin-oct notation: %1
set /a binoctLen=1


rem Вычисление длины строки с исходным числом
:len
for %%i in ("!binoctNum:~0,-%binoctLen%!") do (
    set /a "binoctLen+=1" 
    :: echo "!binoctNum:~0,-%binoctLen%!"
    if not "%binoctNum:~0,1%"=="%%~i" goto len 
)

set dot=
set sign=

rem Позиция разделителя 
set /a dotpos=0
set /a start=0

rem Проверяем наличие знака числа
if "%binoctNum:~0,1%"=="-" (
    set sign=-
    set /a start=1
)

rem Проверка введенного числа на валидность
set /a len="%binoctLen%-1"
set sepCount=0
for /l %%i in (%start%,1,%len%) do (
    if "!binoctNum:~%%i,1!" neq "1" (
        if "!binoctNum:~%%i,1!" neq "0" (
            set bad=1
            if "!binoctNum:~%%i,1!"=="." (
                set /a bad=0
                set /a "sepCount+=1"
                if "!sepCount!"=="2" (
                    set /a bad=1
                    echo Invalid number entered: many separators... & PAUSE & EXIT /b 1
                ) 
            )
            if "!bad!"=="1" (
                echo Invalid number entered: uncorrect value... & PAUSE & EXIT /b 1    
            )   
        )
    )
)

rem Выделяем целую и дробную части
set fracFlag=0
set /a binoctLen-=1
for /l %%i in (%start%,1,%binoctLen%) do (
    if "!binoctNum:~%%i,1!"=="." (
        set dot=.
        set /a dotpos=%%i
        set /a fracFlag=1
    )
)

:: Проверка на триады
set /a checkLen=%binoctLen%-%start%-%fracFlag%+1
set /a checkLen=%checkLen% %% 3
if "!checkLen!" neq "0" (
    echo Invalid number entered: non triads... & PAUSE & EXIT /b 1    
)
echo Number is valid: convertation...

rem Корректировка при наличии разделителя
set wh=0
set fr=0
:check
    if "!dotpos!"=="0" (
        set whole=%binoctNum%
        set dotpos=%binoctLen%
        goto skip
    )

rem Целая часть числа
set whole=!binoctNum:~0,%dotpos%!
set /a dotpos+=1

rem Дробная часть числа 
set frac=!binoctNum:~%dotpos%!
set /a dotpos-=1

:: Выводим целую и дробную части числа 
rem echo Whole part bin-oct: %whole% len: %dotpos%

set /a fracLen=%binoctLen%-%dotpos%
rem echo Frac part bin-oct: %frac% len: %fracLen%


rem Переводим дробную часть в 10 сс
set i=0
set pow2=1
:do
    set "expr1=%pow2%/2"
    for /f %%# in ('"powershell %expr1%"') do set pow2=%%#
    :: set pow2=%pow2:,=.%
    rem echo pow=!pow2! 

    set "expr2=%fr%+%pow2%"
    if "!frac:~%i%,1!"=="1" (
        for /f %%# in ('"powershell %expr2%"') do set fr=%%#
        rem echo fr=%fr% pow=%pow2%
    ) 
    rem echo frac=!fr!  
    set /a "i+=1"

:while
    if %i% lss %fracLen% (
        goto do
    )


set /a dotpos-=1
:skip
    rem Переводим целую часть в 10 сс
    set pow1=1
    for /l %%i in (%dotpos%,-1,0) do (
        if "!whole:~%%i,1!"=="1" (
            set /a "wh+=!pow1!"
            rem echo wh=!wh!
        )
        set /a "pow1*=2"
        rem echo pow=!pow1!
    )


:: Складываем целую и дробную части
for /f %%# in ('"powershell %wh%+%fr%"') do set resdec=%%#
if "!start!"=="1" (
    set resdec=-!resdec!
)
echo Current number in decimal notation: %resdec%

:: Вычисление длины строки с числом в 10 сс
set resdecLen=0
for /f %%i in ('">$ cmd/v/c echo.!resdec!& echo $"') do set/a resdecLen=%%~zi-2& del $
set /a "resdecLen-=1"


rem Переводим обе части в 2-10 сс
for /l %%i in (0,1,%resdecLen%) do (
    if "!resdec:~%%i,1!"=="." ( set part=.) else (
    if "!resdec:~%%i,1!"=="0" ( set part=0000) else (
    if "!resdec:~%%i,1!"=="1" ( set part=0001) else (
    if "!resdec:~%%i,1!"=="2" ( set part=0010) else (
    if "!resdec:~%%i,1!"=="3" ( set part=0011) else (
    if "!resdec:~%%i,1!"=="4" ( set part=0100) else (
    if "!resdec:~%%i,1!"=="5" ( set part=0101) else (
    if "!resdec:~%%i,1!"=="6" ( set part=0110) else (
    if "!resdec:~%%i,1!"=="7" ( set part=0111) else (
    if "!resdec:~%%i,1!"=="8" ( set part=1000) else (
    if "!resdec:~%%i,1!"=="9" ( set part=1001)))))))))))

    set bindec=!bindec!!part!
    rem echo Part output bin-dec: !bindec!
)

:: Конкатенируем знак числа, если он присутствовал
if "!start!"=="1" (
    set bindec=-!bindec!
)
echo Output number in bin-dec notation: %bindec%

PAUSE
