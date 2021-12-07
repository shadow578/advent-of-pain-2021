@echo off
title Day 2, Puzzle 1
setlocal enabledelayedexpansion

:: init sub position
set /a sub_horiz=0
set /a sub_depth=0

:: process line- by- line
for /f "tokens=*" %%l in (input.txt) do (
    :: split into command %%a and value %%b
    for /f "tokens=1,2 delims= " %%a in ("%%l") do (       
        :: process commands
        if "%%a" == "forward" (
            set /a sub_horiz=!sub_horiz! + %%b
        ) else if "%%a" == "up" (
            set /a sub_depth=!sub_depth! - %%b
        ) else if "%%a" == "down" (
            set /a sub_depth=!sub_depth! + %%b
        ) else (
            echo unknown command %%a
        )
    )
)

:: output final position + puzzle answer
set /a puzzle_answer=%sub_horiz% * %sub_depth%
echo final sub position is %sub_horiz% , %sub_depth%
echo puzzle answer: %puzzle_answer%
pause
