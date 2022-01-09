@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: 
::      Clean.bat
::
::      Clean all dangling files
::
:: ==============================================================================
::   cybercastor - made in quebec 2020 <cybercastor@icloud.com>
:: ==============================================================================

goto :init

:init
    set "__script_file=%~0"
    set "__script_path=%~dp0"
    set "__makefile=%__script_path%scripts\make.bat"
    set "__lib_out=%__script_path%scripts\batlibs\out.bat"
    set "__lib_out=%__script_path%scripts\batlibs\out.bat"
    set "__ini_netlib=%__script_path%netlib.ini"
    set "__obj_path=%__script_path%obj"
    set "__bin_path=%__script_path%bin"
    set "__build_cancelled=0"
    goto :clean

:: ==============================================================================
::   make
:: ==============================================================================
:call_make_clean
    set config=%1
    set platform=%2
    call %__makefile% /i %__ini_netlib% /t Clean /c %config% /p %platform%
    goto :finished

:: ==============================================================================
::   Clean on all targets
:: ==============================================================================
:clean_all
    call :call_make_clean Debug x86
    call :call_make_clean Release x86
    call :call_make_clean Debug x64
    call :call_make_clean Release x64
    call :call_make_clean DebugDll x86
    call :call_make_clean ReleaseDll x86
    call :call_make_clean DebugDll x64
    call :call_make_clean ReleaseDll x64
    goto :eof

:rmdirs
    call %__lib_out% :__out_d_yel "Deleting object directory (rmdir obj)"
    rmdir /Q /S %__obj_path%
    call %__lib_out% :__out_d_yel "Deleting binaries directory (rmdir bin)"
    rmdir /Q /S %__bin_path%
    goto :eof

:: ==============================================================================
::   clean
:: ==============================================================================
:clean
    call :clean_all
    call :rmdirs
    goto :finished

:finished
    call %__lib_out% :__out_d_grn "*   *   *   *   *   build complete   *   *   *   *   *"
