@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: 
::      Build.bat
::
::      Build different configuration of the library
::
:: ==============================================================================
::   cybercastor - made in quebec 2020 <cybercastor@icloud.com>
:: ==============================================================================

goto :init

:init
    set "__script_file=%~0"
    set "__script_path=%~dp0"
    set "__makefile=%__script_path%scripts\make\make.bat"
    set "__lib_out=%__script_path%scripts\batlibs\out.bat"
    set "__lib_out=%__script_path%scripts\batlibs\out.bat"
    ::*** This is the important line ***
    set "__build_cfg=%__script_path%zlib.ini"
    set "__build_cancelled=0"
    goto :build

:: ==============================================================================
::   call make
:: ==============================================================================
:call_make_build
    set config=%1
    set platform=%2
    call %__makefile% /i %__build_cfg% /t Build /c %config% /p %platform%
    goto :finished

:: ==============================================================================
::   Build test
:: ==============================================================================
:build_test
    call :call_make_build Debug x64
    goto :eof

:: ==============================================================================
::   Build static
:: ==============================================================================
:build_static
    call :call_make_build Debug x86
    call :call_make_build Release x86
    call :call_make_build Debug x64
    call :call_make_build Release x64
    goto :eof

:: ==============================================================================
::   Build dll
:: ==============================================================================
:build_dll
    call :call_make_build DebugDll x86
    call :call_make_build ReleaseDll x86
    call :call_make_build DebugDll x64
    call :call_make_build ReleaseDll x64
    goto :eof

:: ==============================================================================
::   Build dll
:: ==============================================================================
:build
    call :build_test
   :: call :build_static
   :: call :build_dll
    goto :finished

:finished
    call %__lib_out% :__out_d_grn "*   *   *   *   *   build complete   *   *   *   *   *"
