[Setup]
AppName=Hy Wx Demo
AppVersion=1.0
DefaultDirName={autopf}\HyWxDemo
DefaultGroupName=Hy Wx Demo
UninstallDisplayIcon={app}\runtime\Scripts\hy.exe
Compression=lzma2
SolidCompression=yes
OutputDir=userdocs:Inno Setup Outputs
OutputBaseFilename=Instalador_Hy_Wx_Demo

; --- Captura dinâmica do ambiente virtual do Poetry ---
#define PoetryEnv ExecAndGetFirstLine('cmd.exe', '/c poetry env info --path', SourcePath)
; Garante que o caminho termine com uma barra invertida e adiciona o asterisco para copiar tudo
#define PoetryVenvSource PoetryEnv + '\*'

[Files]
; 1. Copia o conteúdo de ./src para a pasta "pkg" dentro do diretório de instalação
Source: ".\src\*"; DestDir: "{app}\pkg"; Flags: recursesubdirs createallsubdirs ignoreversion

; 2. Copia o ambiente virtual capturado dinamicamente
Source: "{#PoetryVenvSource}"; DestDir: "{app}\runtime"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
; 3. Cria o atalho no Menu Iniciar apontando para o executável do hy.exe com os argumentos corretos
Name: "{group}\Hy Wx Demo"; Filename: "{app}\runtime\Scripts\pythonw.exe"; Parameters: "-m hy pkg\hy_wx_demo\demo.hy"; WorkingDir: "{app}"
; Opcional: Atalho na Área de Trabalho
Name: "{autodesktop}\Hy Wx Demo"; Filename: "{app}\runtime\Scripts\pythonw.exe"; Parameters: "-m hy pkg\hy_wx_demo\demo.hy"; WorkingDir: "{app}"

