@echo off
echo ==============================
echo Compiling Controller_tb testbench
echo ==============================
iverilog -o Controller_tb tb\Controller_tb.v src\Controller.v
if errorlevel 1 (
    echo.
    echo ❌ Compile failed. Fix errors above.
    pause
    exit /b
)

echo.
echo ======================
echo Running Controller_tb ...
echo ======================
vvp Controller_tb

echo.
echo ✅ Simulation finished.
pause