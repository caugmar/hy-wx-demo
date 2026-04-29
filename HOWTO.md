Criar um script que:

1. Crie um diretório para distribuição dentro de ~/temp (por exemplo, ~/temp/dist)
2. Crie dentro desse diretório um subdiretório pkg
3. Dentro de pkg, copie o diretório src do projeto e o venv correspondente
4. Na raiz do dist, crie um shell script que rode:
   ./pkg/venv/bin/python ./pkg/src/hy_wx_demo/run.py
