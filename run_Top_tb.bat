@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo ==============================
echo Compiling Top_tb testbench
echo ==============================

iverilog -g2012 -o Top_tb tb\Top_tb.v src\Top.v src\Controller.v src\Register.v src\Ram.v src\Alu.v src\Incrementer.v

if errorlevel 1 (
    echo.
    echo ❌ Compile failed. Fix errors above.
    pause
    exit /b 1
)

echo.
echo ======================
echo Running Top_tb ...
echo ======================
vvp Top_tb

echo.
echo ✅ Simulation finished.
pause
