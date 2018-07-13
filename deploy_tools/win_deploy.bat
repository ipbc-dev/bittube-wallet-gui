::::::::::::::::::::::::::::::::
:: Bittube Wallet deploy tool ::
::::::::::::::::::::::::::::::::

@ECHO off
SETLOCAL enabledelayedexpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Main section -----------------------------------------------------------
SET "WALLET_ORIGIN_FOLDER=build\release\bin\"
SET "LAUNCHER_ORIGIN_FOLDER=launcher\build\Release\"

SET "DESTINATION_FOLDER=build\deploy\win"
SET "CURRENT_FOLDER=%~dp0"

ECHO Current folder: %CURRENT_FOLDER%

ECHO %CD%
CD ..
CD ..
ECHO %CD%

CALL :cc_dest_folder
CALL :c_origin_folders

CALL :cp_wallet_files
CALL :cp_launcher_files

:paused_and_exit
PAUSE>nul|SET/p =press any key to exit ... 
EXIT %ERRORLEVEL%

:: ------------------------------------------------------------------------
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Function section -------------------------------------------------------

::--------------------
:: Key press waiting
:paused_script

	PAUSE>nul|SET/p =press any key to continue ... 

EXIT /B 0
::--------------------

::--------------------
:: Go to project folder
:main_folder

	CD %CURRENT_FOLDER%
	CD ..

EXIT /B 0
::--------------------

::--------------------
:: Check and create destination folder
:cc_dest_folder

	CALL :main_folder

	IF EXIST "build" (
		ECHO .\build\ Yes 
	) ELSE (
		ECHO .\build\ No
		ECHO Please compile the wallet on ".\build" folder first
		GOTO :paused_and_exit
	)

	IF EXIST "build\deploy" (
		ECHO .\build\deploy\ Yes 
	) ELSE (
		ECHO .\build\deploy\ No
		ECHO Creating ".\build\deploy\" folder 
		MKDIR "build\deploy"
	)

	IF EXIST "build\deploy\win" (
		ECHO .\build\deploy\win\ Yes 
	) ELSE (
		ECHO .\build\deploy\win\ No
		ECHO Creating ".\build\deploy\win" folder 
		MKDIR "build\deploy\win"
	)

EXIT /B 0
::--------------------

::--------------------
:: Check origin folders
:c_origin_folders

	CALL :main_folder

	:: wallet folders
	IF EXIST "build" (
		ECHO .\build\ Yes 
	) ELSE (
		ECHO .\build\ No
		ECHO Please compile the wallet on ".\build" folder first
		GOTO :paused_and_exit
	)

	IF EXIST "build\release" (
		ECHO .\build\release Yes 
	) ELSE (
		ECHO .\build\release No
		ECHO Please compile a release version of the wallet on ".\build\release" folder first
		GOTO :paused_and_exit
	)

	IF EXIST "build\release\bin" (
		ECHO .\build\release\bin Yes 
	) ELSE (
		ECHO .\build\release\bin No
		ECHO ".\build\release\bin" folder lost, check wallet compilation erros
		GOTO :paused_and_exit
	)

	:: launcher folders
	IF EXIST "launcher" (
		ECHO .\launcher\ Yes 
	) ELSE (
		ECHO .\launcher\ No
		ECHO ".\launcher" folder lost, check launcher project
		GOTO :paused_and_exit
	)

	IF EXIST "launcher\build" (
		ECHO .\launcher\build Yes 
	) ELSE (
		ECHO .\launcher\build No
		ECHO Please compile the launcher on ".\launcher\build" folder first
		GOTO :paused_and_exit
	)

	IF EXIST "launcher\build\Release" (
		ECHO .\launcher\build\Release Yes 
	) ELSE (
		ECHO .\launcher\build\Release No
		ECHO Please compile a release version of the launcher on ".\launcher\build\Release" folder first
		GOTO :paused_and_exit
	)

EXIT /B 0
::--------------------

::--------------------
:: Copy wallet files
:cp_wallet_files
	CALL :main_folder

	:: ----------------------------------------------------------------
	:: copy binaries --------------------------------------------------
	IF EXIST "%WALLET_ORIGIN_FOLDER%" (
		ECHO .\%WALLET_ORIGIN_FOLDER% Yes 
	) ELSE (
		ECHO .\%WALLET_ORIGIN_FOLDER% not found
		ECHO Please check the wallet compilation first
		GOTO :paused_and_exit
	)

	IF EXIST "%WALLET_ORIGIN_FOLDER%" (
		ECHO .\%WALLET_ORIGIN_FOLDER% Yes 
	) ELSE (
		ECHO .\%WALLET_ORIGIN_FOLDER% not found
		ECHO Please check the wallet compilation first
		GOTO :paused_and_exit
	)

	:: ----------------------------------------------------------------
	:: copy miner subproject ------------------------------------------
	set miner_files[0]="miner subproject" &:: TODO: create a list of miner files

	set "x=0" 
	:MinerLoop 
	if defined miner_files[%x%] ( 
		set /a "x+=1"
		GOTO :MinerLoop 
	)
	set /a "x-=1"
	for /l %%n in (0,1, %x%) do ( 
		echo !miner_files[%%n]!            &:: TODO: copy every miner file
	)

	:: ----------------------------------------------------------------
	:: copy qt plugin folders -----------------------------------------
	set qt_folders[0]="qt plugin folders" &:: TODO: create a list of qt folders

	set "y=0"
	:QtPluginsLoop 
	if defined qt_folders[%y%] ( 
		set /a "y+=1"
		GOTO :QtPluginsLoop
	) 
	set /a "y-=1"
	for /l %%n in (0,1,%y%) do ( 
		echo !qt_folders[%%n]!            &:: TODO: copy every qt folder
	)

	:: ----------------------------------------------------------------
	:: shared libraries .dll ------------------------------------------
	set dll_files[0]="shared libraries" &:: TODO: create a list of dll libraries

	set "z=0"
	:DllLibsLoop
	if defined dll_files[%z%] ( 
		set /a "z+=1"
		GOTO :DllLibsLoop
	)
	set /a "z-=1"
	for /l %%n in (0,1,%z%) do ( 
		echo !dll_files[%%n]!             &:: TODO: copy every dll file
	)
EXIT /B 0
::--------------------

::--------------------
:: Copy launcher files
:cp_launcher_files
	CALL :main_folder

	IF EXIST "%LAUNCHER_ORIGIN_FOLDER%bittube-launcher.exe" (
		ECHO .\%LAUNCHER_ORIGIN_FOLDER%bittube-launcher.exe Yes 
	) ELSE (
		ECHO .\%LAUNCHER_ORIGIN_FOLDER%bittube-launcher.exe not found
		ECHO Please check the launcher compilation first
		GOTO :paused_and_exit
	)

	IF EXIST "%LAUNCHER_ORIGIN_FOLDER%bittube-launcher-low.exe" (
		ECHO .\%LAUNCHER_ORIGIN_FOLDER%bittube-launcher-low.exe Yes 
	) ELSE (
		ECHO .\%LAUNCHER_ORIGIN_FOLDER%bittube-launcher-low.exe not found
		ECHO Please check the launcher compilation first
		GOTO :paused_and_exit
	)

EXIT /B 0
::--------------------

:: ------------------------------------------------------------------------
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: DEV-HELP SECTION
:: 
:: [Checking if a folder exists using a .bat file](https://stackoverflow.com/questions/21033801/checking-if-a-folder-exists-using-a-bat-file)
::
::IF EXIST yourfilename (
::echo Yes 
::) ELSE (
::echo No
::)
::
::---------------------------------------------------------------------------------------------------------------------------------------------
::
:: [Batch file to copy directories recursively](https://stackoverflow.com/questions/13314433/batch-file-to-copy-directories-recursively)
:: [xcopy](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/xcopy)
::
::    To copy all the files and subdirectories (including any empty subdirectories) from drive A to drive B, type:
::
::    xcopy a: b: /y /s /e
::
::
::---------------------------------------------------------------------------------------------------------------------------------------------
::
:: [Copy file from batch file's directory](https://stackoverflow.com/questions/19303155/copy-file-from-batch-files-directory)
::
:: copy "%~dp0\Move.txt" "C:\"
::
::---------------------------------------------------------------------------------------------------------------------------------------------
::
:: [Batchfile: What's the best way to declare and use a boolean variable?](https://stackoverflow.com/questions/35544871/batchfile-whats-the-best-way-to-declare-and-use-a-boolean-variable)
::
:: set "condition="
:: if defined condition (echo true) else (echo false)
::
:: set "condition=y"
:: if defined condition (echo true) else (echo false)
::
:: The first will echo false, the second true
::
::---------------------------------------------------------------------------------------------------------------------------------------------
::
:: [Creating an Array](https://www.tutorialspoint.com/batch_script/batch_script_arrays.htm)
::
:: @echo off 
:: setlocal enabledelayedexpansion 
:: set topic[0]=comments 
:: set topic[1]=variables 
:: set topic[2]=Arrays 
:: set topic[3]=Decision making 
:: set topic[4]=Time and date 
:: set topic[5]=Operators 

:: for /l %%n in (0,1,5) do ( 
::    echo !topic[%%n]! 
:: )