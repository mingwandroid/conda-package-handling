REM From scratch avoiding most conda stuff because when this is broken conda is broken

rd /s /q C:\opt\conda.cph
rd /s /q C:\opt\cph-build
doskey conda=
set CONDA_BAT=
set CONDA_DEFAULT_ENV=
set CONDA_EXE=
set CONDA_PREFIX=
set CONDA_PROMPT_MODIFIER=
set CONDA_PYTHON_EXE=
set CONDA_SHLVL=
set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;c:\Program Files (x86)\Microsoft SQL Server\90\Tools\binn\;C:\Program Files\dotnet\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\HashiCorp\Vagrant\bin;C:\Users\rdonnelly\AppData\Local\Microsoft\WindowsApps;C:\Users\rdonnelly\AppData\Local\Programs\Microsoft VS Code\bin;C:\Program Files\JetBrains\PyCharm Professional Edition with Anaconda plugin 2019.2.1\bin;C:\Users\rdonnelly\gd.cio\bin

pushd C:\opt
  if not exist mc3.exe powershell -NoProfile -command "& { (New-Object Net.WebClient).DownloadFile('https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.exe', 'mc3.exe') }"
  if not exist C:\opt\conda.cph start /wait "" mc3.exe /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /NoRegistry=0 /S /D=C:\opt\conda.cph
  call C:\opt\conda.cph\Scripts\activate.bat
  conda update -y --all
  conda install -y git vs2017_win-64 cython _libarchive_static_for_cph
  conda install -y --only-deps conda-build
  conda list
  set LIB=%CONDA_PREFIX%\Library\lib;%LIB%
  set INCLUDE=%CONDA_PREFIX%\Library\include;%INCLUDE%

  mkdir cph-build
  pushd cph-build
    git clone C:\opt\asrc\conda-package-handling work
    pushd work
      git clone https://github.com/libarchive/libarchive libarchive
      pushd libarchive
        git checkout v3.3.3
        Powershell -NoProfile -command "$files=$(ls C:\opt\asrc\conda-package-handling\libarchive-patches\*.patch | % {$_.FullName}) ; git.exe am -3 $files.replace('\', '/')"
        python setup.py develop
      popd
    popd
  popd
popd

pushd C:\opt\asrc\conda-package-handling
  mkdir empty
  robocopy /is /it /mir empty build
  rd /s /q empty
  call conda activate base
  call conda install _libarchive_static_for_cph
  set LIB=%CONDA_PREFIX%\Library\lib
  set INCLUDE=%CONDA_PREFIX%\Library\include
  python setup.py develop -v -v -v
popd
