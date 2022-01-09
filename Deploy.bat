@echo off


:: ==============================================================================
:: 
::      Deploy.bat
::
::      Deploy library
::
:: ==============================================================================
::   cybercastor - made in quebec 2020 <cybercastor@icloud.com>
:: ==============================================================================

goto :init



:header
    echo. %__script_name% v%__script_version%
    echo.    Script to deploy binaries of my lib
    echo.
    goto :eof

:usage
    echo. Usage:
    echo. %__script_name% [flags] 
    echo.
    echo.      /?, --help           shows this help
    echo.      /e, --verbose        shows detailed output
    echo.      -l, --log level      specifies the log level (0 no logs to 3 diagnostic/fullmayhem)
    echo.      /s, --source         Source directory
    echo.      /d, --destination    Destination directory
    echo.      /c, --clean          Clean: delete destination directory before copy
    echo.
    goto :eof

:notes
    echo Notes:
    echo.     - This file is used by my profiles in Windows Terminal to launch VS and set
    echo.       environment settings. It is important to keep it up to date and add supported
    echo.       version when I install them.
    echo.
    goto :eof


:missing_argument
    call :header
    call :usage
    call :error_missing_arguments
    echo.
    goto :eof

:init
    set "__script_file=%~0"
    set "__script_path=%~dp0"
    set "__makefile=%__script_path%scripts\make.bat"
    set "__lib_out=%__script_path%scripts\batlibs\out.bat"
    set "__lib_date=%__script_path%scripts\batlibs\date.bat"
    set "__ini_netlib=%__script_path%netlib.ini"
    set "__obj_path=%__script_path%obj"
    set "__bin_path=%__script_path%bin"
    set "__src_path=%__script_path%src"
    set "__export_root=%__script_path%..\..\externals\netlib"
    set "__build_cancelled=0"
    set "__debug_default_log_path=%temp%\CUSTOM_SCRIPTS_LOGS"
    set "__debug_default_log_file=%__debug_default_log_path%\Deploy.log"
    set __vscmd_log_level_desc_0="No Logging"
    set __vscmd_log_level_desc_1="Minimal"
    set __vscmd_log_level_desc_2="Detailed"
    set __vscmd_log_level_desc_3="FullLogs Diagnostic"
    set "__debug_log_file="
    set "__debug_log_level="
    set "__opt_dst_path="
    set "__opt_dst_includes_path="
    set "__opt_src_path="
    set "__opt_verbose="
    set __sync_started=1
    set __sync_completed=0
    set __sync_return=0
    call %__lib_out% :writeInitialize


:parse
    if "%~1"=="" goto :checklibs

    if /i "%~1"=="/?"         call :header & call :usage & call :notes "%~2" & goto :eof
    if /i "%~1"=="-?"         call :header & call :usage & call :notes "%~2" & goto :eof
    if /i "%~1"=="/h"         call :header & call :usage & call :notes "%~2" & goto :eof
    if /i "%~1"=="-h"         call :header & call :usage & call :notes "%~2" & goto :eof
    if /i "%~1"=="--help"     call :header & call :usage & call :notes "%~2" & goto :eof

    if /i "%~1"=="/v"         set "__opt_verbose=yes"  & shift & shift & goto :parse
    if /i "%~1"=="-v"         set "__opt_verbose=yes"  & shift & shift & goto :parse
    if /i "%~1"=="--verbose"  set "__opt_verbose=yes"  & shift & shift & goto :parse

    if /i "%~1"=="-l"         set "__debug_log_level=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="/l"         set "__debug_log_level=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="--log"      set "__debug_log_level=%~2"   & shift & shift & goto :parse

    if /i "%~1"=="-s"           set "__opt_src_path=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="/s"           set "__opt_src_path=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="--source"     set "__opt_src_path=%~2"   & shift & shift & goto :parse

    if /i "%~1"=="-d"             set "__opt_dst_path=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="/d"             set "__opt_dst_path=%~2"   & shift & shift & goto :parse
    if /i "%~1"=="--destination"  set "__opt_dst_path=%~2"   & shift & shift & goto :parse

    if /i "%~1"=="-c"           set "__opt_clean=yes"   & shift & shift & goto :parse
    if /i "%~1"=="/c"           set "__opt_clean=yes"   & shift & shift & goto :parse
    if /i "%~1"=="--clean"     set "__opt_clean=yes"   & shift & shift & goto :parse
    shift
    goto :parse

:checklibs
    call :print_step_title "deploy steps: check batch files libs" ""
    if not exist %__lib_out%  call :error_missing_lib %__lib_out% & goto :eof
    if not exist %__lib_date% call :error_missing_lib %__lib_date% & goto :eof
    call %__lib_out% :writeCl "check libs %$write.sub%OK!"

:create_externals
        pushd "%__script_path%..\..\"
        set __service_root=%cd%
        ::call %__lib_out% :__out_d_whi "__service_root %__service_root%"
        if not exist externals ( 
            mkdir externals 
            )
        pushd externals
        set __externals_root=%cd%
        ::call %__lib_out% :__out_d_whi "__externals_root %__externals_root%"
        if not exist netlib ( mkdir netlib )
        pushd netlib
        set __exported_lib_root=%cd%
        ::call %__lib_out% :__out_d_whi "__exported_lib_root %__exported_lib_root%"
        if not exist bin ( mkdir bin )
        if not exist src ( mkdir src )
        pushd src
        set __opt_dst_includes_path=%cd%
        ::call %__lib_out% :__out_d_whi "__opt_dst_includes_path %__opt_dst_includes_path%"
        popd
        pushd bin
        set __opt_dst_path=%cd%
        ::call %__lib_out% :__out_d_whi "__opt_dst_path %__opt_dst_path%"
        popd
        popd
        popd
        popd
        ::call %__lib_out% :writeCl "%$write.sub%OK!"

:setdefaults
    call :print_step_title "deploy settings: defaults" ""
    if "" == "%TEMP%" set "TEMP=%SYSTEMDRIVE%\Windows\Temp"
    
    popd
    if "" == "%__opt_src_path%" (
       set "__opt_src_path=%__bin_path%"
       if  "%__opt_verbose%" equ "yes" (
            call %__lib_out% :__out_d_red " ***NOTE*** will be using the default source folder %__opt_src_path%"
        )
    )
    if "" == "%__debug_log_level%" (
        set __debug_log_level=2
        )
    
   
:set_default_logfile
    call :print_step_title "deploy settings: logs" "log file directory %__debug_default_log_path%. default log file %__debug_default_log_file%"
    if not exist %__debug_default_log_path% (
        call %__lib_out% :__out_d_whi "Creating directory %__debug_default_log_path%"
        mkdir %__debug_default_log_path%
        call %__lib_out% :writeCl "log config defaults %$write.sub%OK!"
        
        )
    if "" == "%__debug_log_file%" (
        set "__debug_log_file=__debug_default_log_file"
        call %__lib_out% :__out_d_red " ***NOTE*** will be using the default log file value %__debug_default_log_file%"
        call %__lib_out% :__out_d_red "To change this, use the /f (-f --file) cmdline option."
        )

:validate
    call :print_step_title "deploy step: params validation" "source: %__opt_src_path%, destination: %__opt_dst_path%"
    if not exist "%__opt_src_path%" (
        call :error_src_folder_not_exists %__opt_src_path% & goto :eof
        )
    set __opt_loglevel_valid="no"
    if "%__debug_log_level%" equ "0" (
        set __opt_loglevel_valid="yes"
        set VSCMD_DEBUG_STR=%__vscmd_log_level_desc_0%
        )
    if "%__debug_log_level%" equ "1" (
        set __opt_loglevel_valid="yes"
        set VSCMD_DEBUG_STR=%__vscmd_log_level_desc_1%
        )
    if "%__debug_log_level%" equ "2" (
        set __opt_loglevel_valid="yes"
        set VSCMD_DEBUG_STR=%__vscmd_log_level_desc_2%
        )
 
    if "%__opt_loglevel_valid%" == "no" (
        call :error_invalid_log_level %__debug_log_level% & goto :eof
        )
    call :print_step_title "deploy settings: logs" "log leel: %__debug_log_level%,: %VSCMD_DEBUG_STR%"
    goto :execute



:: ==============================================================================
::   start_xcopy
:: ==============================================================================
:start_xcopy
    call :print_step_title "deploy step: start xcopy" "set flags and launch copy loop"
    set __sync_started=0
    set __sync_completed=0
    goto :eof

:: ==============================================================================
::   xcopy_sync
:: ==============================================================================
:xcopy_exec
    set __arg_src=%1
    set __arg_dst=%2
    call :print_step_title "deploy step: xcopy exec" "starting xcopy execution task sync. Log level: %__debug_log_level%"

    if "%__sync_started%" equ "0" (
        set __sync_started=1
        if %__debug_log_level% == 0 (
            :: Sync, but do not display details
            xcopy /d /e /s /y /q  %__arg_src% %__arg_dst% > nul
            )
        if %__debug_log_level% == 1 (
            :: Sync source to dest, only copy files that have changed
            xcopy /d /e /s /y %__arg_src% %__arg_dst% > nul
            )
        if %__debug_log_level% == 2 (
            :: Same but with full path
            xcopy /d /e /s /y /q %__arg_src% %__arg_dst%  > nul
            )
        call %__lib_out% :writeCl "Exported libraries from binary folder %$write.sub%OK!"
            set __sync_started=1
            set __sync_completed=1
            set __sync_return=0
    ) else (
        call :error_xcopy_already_Started %errorlevel% & goto :eof
    )
    goto :eof



:: ==============================================================================
::   checks for a header file header signature to determine 
::   if we export this header or not
:: ==============================================================================
:check_header_deploy_signature
    set __header_file=%1
    for /F "tokens=1,2 delims==" %%i in ('findstr /I "exported_h" %__header_file%') do (
        copy /y %__header_file% %__opt_dst_includes_path% > nul
        call %__lib_out% :write " . "
      )
   
    goto :eof
   
    
:: ==============================================================================
::   parse_headers
:: ==============================================================================
:parse_headers    
    call %__lib_out% :writeCl "Exported header files from source folder %$write.sub%OK!"
    ::call :print_step_title "deploy step: parse headers" "parsing headers to determine if they need to be exported to destination: %__arg_dst%"
    pushd %__src_path%
    echo.
    call %__lib_out% :write "Exported header files: "
    for /R %%f in (*.h) do call :check_header_deploy_signature %%f
    popd
    echo.
    goto :eof

:delete_directory
    set __arg_dir=%1
    call :print_step_title "deploy step: delete directory" ""
    call %__lib_out% :__out_d_red "delete destination directory for a clean state. path: %__arg_dir%"
    rmdir /Q /S %__arg_dir%
    if %errorlevel% equ 0 (
        call %__lib_out% :writeCl "%$write.sub%OK!"
        call %__lib_out% :__out_l_grn " delete ok"
        ) else (
            call :error_rmdir %errorlevel% & goto :eof
    )
    goto :eof

:print_step_title
    set __title_str="%1"
    set __desc_str="%2"
    if  "%__opt_verbose%" equ "yes" (
         call %__lib_out% :__out_d_red "=============================================================================="
         call %__lib_out% :__out_l_whi "   ----- %__title_str%"
         call %__lib_out% :__out_d_whi "   ----- %__desc_str%"
         call %__lib_out% :__out_d_red "=============================================================================="
    ) 
    goto :eof

:: ==============================================================================
::   execute
:: ==============================================================================
:execute
    call :print_step_title "deploy step: execute" "running the copy processes. destination: %__opt_dst_path%"
   
    call :start_xcopy
    if "%__opt_clean%" equ "yes" (
        call %__lib_out% :__out_d_red "=============================================================================="
        call %__lib_out% :__out_d_yel "clean option was specified: deleting destination %__opt_dst_path%"
        call %__lib_out% :__out_d_red "=============================================================================="
        call :delete_directory %__opt_dst_path%
        call :delete_directory %__opt_dst_includes_path%
    )

    if not exist %__opt_dst_path% ( mkdir  %__opt_dst_path% )
    if not exist %__opt_dst_includes_path% ( mkdir  %__opt_dst_includes_path% )

    call :xcopy_exec %__opt_src_path% %__opt_dst_path%
    if "%__sync_return%" equ "0" (
        if  "%__opt_verbose%" equ "yes" (
            call :print_step_title "verbose mode: dump file list" "Listing all the files in the destination directory after copy: %__opt_dst_path%"
            call %__lib_out% :__out_d_red "=============================================================================="
            dir /b /s %__opt_dst_path%
            call %__lib_out% :__out_d_red "=============================================================================="
            )
        )
    call :parse_headers 
    goto :finished

:debug_dump_vars
    call %__lib_out% :__out_d_red "=============================================================================="
    call %__lib_out% :__out_d_red "DEBUG VALUE USED IN THIS SCRIPT"
    call %__lib_out% :__out_d_red "=============================================================================="
    call %__lib_out% :__out_d_yel "%__script_file=%"
    call %__lib_out% :__out_d_yel "%__script_path=%"
    call %__lib_out% :__out_d_yel %__vs2015_path%
    call %__lib_out% :__out_d_yel "%__vs_admin%"
    call %__lib_out% :__out_d_yel "%__debug_log_level%"
    call %__lib_out% :__out_d_yel "%__opt_src_path%"
    call %__lib_out% :__out_d_yel "%__opt_dst_path%"
    call %__lib_out% :__out_d_yel "%__vs_setenv%"
    call %__lib_out% :__out_d_yel "%__lib_date%"
    call %__lib_out% :__out_d_yel "%__lib_out%"
    call %__lib_out% :__out_d_yel "%__opt_verbose%"
    call %__lib_out% :__out_d_yel "%__opt_clean%"
    goto :eof

:error_xcopy
    echo.
    call %__lib_out% :__out_l_red "   deploy error"
    call %__lib_out% :__out_d_yel "   Xcopy failed with error %1."
    echo.
    goto :eof
:error_xcopy_already_Started
    echo.
    call %__lib_out% :__out_l_red "   deploy error"
    call %__lib_out% :__out_d_red "   execution task sync already started. bailing."
    echo.
    goto :eof
:error_folder_creation
    echo.
    call %__lib_out% :__out_l_red "   deploy error"
    call %__lib_out% :__out_d_yel "   Error when creating folder %1."
    echo.
    goto :eof
:error_src_folder_not_exists
    echo.
    call %__lib_out% :__out_l_red "   deploy error"
    call %__lib_out% :__out_d_yel "   Source folder does not exists %1"
    echo.
    goto :eof
:error_invalid_log_level
    echo.
    call %__lib_out% :__out_l_red "   deploy config error"
    call %__lib_out% :__out_d_yel "   Invalid log level (%1). Specify using /c. Type /h for usage."
    echo.
    goto :eof
:error_src_folder_not_exists
    echo.
    call %__lib_out% :__out_l_red "   deploy error"
    call %__lib_out% :__out_d_yel "   Source folder does not exists %1"
    echo.
    goto :eof
:error_file_unreadable
    echo.
    call %__lib_out% :__out_l_red "   deploy error"
    call %__lib_out% :__out_d_yel "   Source file cannot be located or read: %1"
    echo.
    goto :eof

:error_rmdir
    echo.
    call %__lib_out% :__out_l_red "   deploy error"
    call %__lib_out% :__out_d_yel "   directory cannot be deleted: %1"
    echo.
    goto :eof
:finished
    call %__lib_out% :__out_d_grn "*   *   *   *   *   deploy complete   *   *   *   *   *"

