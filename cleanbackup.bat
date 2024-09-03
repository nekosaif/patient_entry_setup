@echo off
setlocal enabledelayedexpansion

set "config_file=cleanbackup.config"
set "SqlServerName="
set "MaxBackupNumber="

for /f "tokens=1,2 delims==" %%a in (%config_file%) do (
    set "%%a=%%b"
)

set "backupFilePath=C:\Program Files\Microsoft SQL Server\MSSQL12.%SqlServerName%\MSSQL\Backup"

echo SqlServerName: %SqlServerName%
echo MaxBackupNumber: %MaxBackupNumber%
echo backupFilePath: %backupFilePath%

set "fileCount=0"
for %%F in ("%backupFilePath%\*") do set /a fileCount+=1

echo Number of files before cleanup: %fileCount%

rem Compare fileCount with MaxBackupNumber
set /a "filesToDelete=%fileCount%-%MaxBackupNumber%"

if %filesToDelete% gtr 0 (
    echo Deleting excess files...
    set "counter=0"
    for /f "delims=" %%F in ('dir /b /o:n "%backupFilePath%\*"') do (
        if !counter! lss %filesToDelete% (
            del "%backupFilePath%\%%F"
            echo Deleted: %%F
            set /a "counter+=1"
        ) else (
            goto :done_deleting
        )
    )
    :done_deleting
    echo Deleted %counter% files.
) else (
    echo No files need to be deleted.
)

set "fileCount=0"
for %%F in ("%backupFilePath%\*") do set /a fileCount+=1

echo Number of files after cleanup: %fileCount%