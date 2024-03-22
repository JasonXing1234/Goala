@echo off
rem These commands will fix the code and make some format changes.
rem This should be run before we update the app and before major revisions.
rem
rem To run this use the following commands
rem     Windows: .\custom_dart_fix.bat

echo -------- Prefer const constructors
call dart fix --code="prefer_const_constructors" .\lib --apply
echo -------- Remove unused imports
call dart fix --code=unused_import .\lib --apply