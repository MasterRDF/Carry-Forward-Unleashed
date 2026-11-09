@echo off
rem Carry Forward Unleashed 1.5: removes the files left over from 1.4.1 and older (the mod is now one folder,
rem kronos\mods\carry_forward_unleashed). Run it from your cod25 folder. It deletes only the five paths below.
cd /d "%~dp0"
if not exist "cod25-cod.exe" (
    echo This is not your cod25 folder. Put cleanup.bat next to cod25-cod.exe and run it again.
    pause
    exit /b 1
)
for %%D in ("mw2_guns" "kronos\mods\mwcf_box" "kronos\mods\mwcf_categories" "kronos\mods\mwcf_pap" "kronos\mods\mw_zm_loadout") do (
    if exist %%D (
        rmdir /s /q %%D
        if exist %%D (echo Could not remove %%~D - close the game and try again) else (echo Removed %%~D)
    ) else (
        echo Already gone: %%~D
    )
)
echo Done.
pause
