@echo off
echo ==============================
echo Compiling regfile_tb testbench
echo ==============================
iverilog -o regfile_tb tb\regfile_tb.v src\regfile.v
if errorlevel 1 (
    echo.
    echo ❌ Compile failed. Fix errors above.
    pause
    exit /b
)

echo.
echo ======================
echo Running regfile_tb ...
echo ======================
vvp regfile_tb

echo.
echo ✅ Simulation finished.
pause
