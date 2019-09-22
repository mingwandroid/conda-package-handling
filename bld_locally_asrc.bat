REM From scratch avoiding most conda stuff because when this is broken conda is broken

REM *****************
REM * CONFIGURATION *
REM *****************
REM Change these
:REM Where to install everything. %CD% is probably better though
set ROOT_OF_THIS=C:\opt
REM Set to nothing to build from source
REM set LIBARCHIVE_PACKAGE=_libarchive_static_for_cph
REM set LIBARCHIVE_PACKAGE=
REM ************************
REM * END OF CONFIGURATION *
REM ************************

REM Leave these alone:
if "%LIBARCHIVE_PACKAGE%" == "" set LIBARCHIVE_BUILD_DEPS=cmake ninja bzip2 libiconv zlib zstd
rd /s /q %ROOT_OF_THIS%\conda.cph
doskey conda=
set CONDA_BAT=
set CONDA_DEFAULT_ENV=
set CONDA_EXE=
set CONDA_PREFIX=
set CONDA_PROMPT_MODIFIER=
set CONDA_PYTHON_EXE=
set CONDA_SHLVL=
set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;c:\Program Files (x86)\Microsoft SQL Server\90\Tools\binn\;C:\Program Files\dotnet\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\HashiCorp\Vagrant\bin;C:\Users\rdonnelly\AppData\Local\Microsoft\WindowsApps;C:\Users\rdonnelly\AppData\Local\Programs\Microsoft VS Code\bin;C:\Program Files\JetBrains\PyCharm Professional Edition with Anaconda plugin 2019.2.1\bin

pushd %ROOT_OF_THIS%
  if not exist mc3.exe powershell -NoProfile -command "& { (New-Object Net.WebClient).DownloadFile('https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.exe', 'mc3.exe') }"
  if not exist %ROOT_OF_THIS%\conda.cph start /wait "" mc3.exe /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /NoRegistry=0 /S /D=%ROOT_OF_THIS%\conda.cph
  call %ROOT_OF_THIS%\conda.cph\Scripts\activate.bat
  set PATH_BACKUP=%PATH%
  call conda update -y --all
  call conda install -y git vs2017_win-64 cython %LIBARCHIVE_PACKAGE% %LIBARCHIVE_BUILD_DEPS%

  REM Repeated calls to conda install blow our PATH up due to vs2017_win-64 constant reactivation.
  set PATH=%PATH_BACKUP%
  call conda install -y --only-deps conda-build
  call conda list
  set LIB=%CONDA_PREFIX%\Library\lib;%LIB%
  set INCLUDE=%CONDA_PREFIX%\Library\include;%INCLUDE%

pushd conda.cph
  git clone %~dp0 work
  pushd work
    if not "%LIBARCHIVE_PACKAGE%" == "" goto skip_build
    git clone https://github.com/libarchive/libarchive libarchive
    pushd libarchive
      git checkout v3.3.3
      Powershell -NoProfile -command "$files=$(ls %~dp0libarchive-patches\*.patch) ; git.exe am -3 $files"
    popd
    if not exist CMakeCache.txt cmake -G "Ninja" ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS:BOOL=FALSE ^
        -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
        -DCMAKE_C_FLAGS_RELEASE="%CFLAGS%" ^
        -DENABLE_ACL=ON ^
        -DENABLE_BZip2=ON ^
        -DENABLE_CAT=OFF ^
        -DENABLE_CNG=NO ^
        -DENABLE_COVERAGE=OFF ^
        -DENABLE_CPIO=OFF ^
        -DENABLE_EXPAT=ON ^
        -DENABLE_ICONV=OFF ^
        -DENABLE_INSTALL=ON ^
        -DENABLE_LIBB2=OFF ^
        -DENABLE_LIBXML2=OFF ^
        -DENABLE_LZ4=OFF ^
        -DENABLE_LZMA=OFF ^
        -DENABLE_LZO=OFF ^
        -DENABLE_LibGCC=OFF ^
        -DENABLE_NETTLE=OFF ^
        -DENABLE_OPENSSL=OFF ^
        -DENABLE_SAFESEH=AUTO ^
        -DENABLE_TAR=ON ^
        -DENABLE_TAR_SHARED=OFF ^
        -DENABLE_XATTR=ON ^
        -DENABLE_ZLIB=ON ^
        -DENABLE_ZSTD=ON ^
        -DBZIP2_LIBRARY_RELEASE=%CONDA_PREFIX%/Library/lib/bzip2_static.lib ^
        -DZLIB_LIBRARY_RELEASE=%CONDA_PREFIX%/Library/lib/zlibstatic.lib ^
        -DZSTD_LIBRARY=%CONDA_PREFIX%/Library/lib/libzstd_static.lib ^
        libarchive
    ninja -j12 -v
    if errorlevel 1 exit /b 1
    ninja install
    if errorlevel 1 exit /b 1
    pushd %CONDA_PREFIX%\Library\lib
      lib.exe /OUT:archive_and_deps.lib archive_static.lib libzstd_static.lib bzip2_static.lib zlibstatic.lib
    popd
:skip_build
    python setup.py develop
  popd
popd
