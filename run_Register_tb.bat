@echo off
echo ==============================
echo Compiling Register_tb testbench
echo ==============================
iverilog -o Register_tb tb\Register_tb.v src\Register.v
if errorlevel 1 (
    echo.
    echo ❌ Compile failed. Fix errors above.
    pause
    exit /b
)

echo.
echo ======================
echo Running Register_tb ...
echo ======================
vvp Register_tb

echo.
echo ✅ Simulation finished.
pause
