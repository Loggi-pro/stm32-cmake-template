@echo off
SETLOCAL EnableDelayedExpansion
rem echo %1
set "spaces=                        "
set "flashspaces=             "
set /a TOTAL_FLASH=0
set /a TOTAL_RAM=0
echo	FILENAME                FLASH        RAM
for /f "skip=1 tokens=1,2,3,6" %%A in (%1) do (  
	set /a TEXT=%%A 
	set /a DATA=%%B 
	set /a BSS=%%C
	set FILENAME=%%D
	set /a FLASH=!TEXT!+!DATA!
	set /a RAM=!DATA!+!BSS!
	for %%F in (!FILENAME!) do set NAME=%%~nxF
	set PADDED=!NAME!%spaces%
	set PADDEDF=!FLASH!%flashspaces%
	echo !PADDED:~0,24!!PADDEDF:~0,13!!RAM!
	set /a TOTAL_FLASH=!TOTAL_FLASH!+!FLASH!
	set /a TOTAL_RAM=!TOTAL_RAM!+!RAM!
	rem print only filename
	rem echo.!name!	!FLASH!	!RAM!
)
echo _________________________________________
set PADDEDF=!TOTAL_FLASH!%flashspaces%
set PADDEDS=SUMMARY%spaces%
echo !PADDEDS:~0,24!!PADDEDF:~0,13!!TOTAL_RAM!




