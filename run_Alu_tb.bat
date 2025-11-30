@echo off
echo ==============================
echo Compiling Alu_tb testbench
echo ==============================
iverilog -o Alu_tb tb\Alu_tb.v src\Alu.v
if errorlevel 1 (
    echo.
    echo ❌ Compile failed. Fix errors above.
    pause
    exit /b
)

echo.
echo ======================
echo Running Alu_tb ...
echo ======================
vvp Alu_tb

echo.
echo ✅ Simulation finished.
pause