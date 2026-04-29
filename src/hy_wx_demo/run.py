import hy
import sys
import os

# Garante que o diretório atual está no path para encontrar os arquivos .hy
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

try:
    # Substitua pelo nome do seu arquivo .hy (sem a extensão)
    from hy_wx_demo import demo

    demo.main()  # Chama a função de entrada do seu Lisp
except Exception as e:
    print(f"Erro ao carregar o app Hy: {e}")
