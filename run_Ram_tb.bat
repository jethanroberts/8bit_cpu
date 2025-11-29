@echo off
echo ==============================
echo Compiling Ram_tb testbench
echo ==============================
iverilog -o Ram_tb tb\Ram_tb.v src\Ram.v
if errorlevel 1 (
    echo.
    echo ❌ Compile failed. Fix errors above.
    pause
    exit /b
)

echo.
echo ======================
echo Running Ram_tb ...
echo ======================
vvp Ram_tb

echo.
echo ✅ Simulation finished.
pause
