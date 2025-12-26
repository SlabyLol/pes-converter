@echo off
setlocal EnableExtensions EnableDelayedExpansion

set INSTALL_DIR=%~dp0PES_Converter
mkdir "%INSTALL_DIR%" 2>nul

python --version >nul 2>&1
if errorlevel 1 (
    set PYTHON_INSTALLER=python-installer.exe
    powershell -Command "Invoke-WebRequest https://www.python.org/ftp/python/3.12.1/python-3.12.1-amd64.exe -OutFile %PYTHON_INSTALLER%"
    %PYTHON_INSTALLER% /quiet InstallAllUsers=1 PrependPath=1 Include_pip=1
)

python -m pip install --upgrade pip
pip install tkinterdnd2

set PYFILE=%INSTALL_DIR%\pes_converter.py

> "%PYFILE%" (
echo import subprocess
echo from pathlib import Path
echo import tkinter as tk
echo from tkinter import ttk, messagebox
echo from tkinterdnd2 import DND_FILES, TkinterDnD
echo.
echo SUPPORTED = [".png", ".jpg", ".jpeg", ".bmp"]
echo OUTPUT_DIR = Path("pes")
echo OUTPUT_DIR.mkdir(exist_ok=True)
echo.
echo class PESConverterApp(TkinterDnD.Tk):
echo ^    def __init__(self):
echo ^        super().__init__()
echo ^        self.title("Image to PES Converter")
echo ^        self.geometry("500x300")
echo ^        self.files = []
echo.
echo ^        label = tk.Label(self, text="Drop images here", relief="ridge", width=60, height=8)
echo ^        label.pack(pady=20)
echo ^        label.drop_target_register(DND_FILES)
echo ^        label.dnd_bind("<<Drop>>", self.drop_files)
echo.
echo ^        self.progress = ttk.Progressbar(self, length=400, mode="determinate")
echo ^        self.progress.pack(pady=10)
echo.
echo ^        self.status = tk.Label(self, text="Ready")
echo ^        self.status.pack()
echo.
echo ^        btn = tk.Button(self, text="Convert", command=self.convert)
echo ^        btn.pack(pady=10)
echo.
echo ^    def drop_files(self, event):
echo ^        paths = self.tk.splitlist(event.data)
echo ^        self.files = [Path(p) for p in paths if Path(p).suffix.lower() in SUPPORTED]
echo ^        self.status.config(text=f"{len(self.files)} file(s) loaded")
echo.
echo ^    def convert(self):
echo ^        self.progress["maximum"] = len(self.files)
echo ^        self.progress["value"] = 0
echo ^        for i, img in enumerate(self.files, 1):
echo ^            out = OUTPUT_DIR / f"{img.stem}.pes"
echo ^            subprocess.run(["inkscape.com", str(img), "--actions=inkstitch-params;inkstitch-export-pes", f"--export-filename={out}"], check=True)
echo ^            self.progress["value"] = i
echo ^            self.update_idletasks()
echo.
echo if __name__ == "__main__":
echo ^    app = PESConverterApp()
echo ^    app.mainloop()
)

> "%INSTALL_DIR%\start_converter.bat" (
echo @echo off
echo cd /d "%%~dp0"
echo python pes_converter.py
)

pause
