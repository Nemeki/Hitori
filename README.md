Ubicar la terminal en la carpeta Hitori raíz del proyecto. Luego, ejecutar el siguiente comando para compilar:

  $ nvcc hitori.cu  

Para ejectuar el archivo "a.exe" generado utilizar el siguiente comando:

  $ a.exe "filename.txt"

donde filename.txt corresponde al nombre del archivo de entrada el cual es una matriz (Hitori) con el siguiente formato de ejemplo:

"""
5
4 1 5 3 2
1 2 3 5 5
3 4 4 5 1
3 5 1 5 4
5 2 5 1 3
"""
la primera fila del archivo contiene el valor de la dimensión de la matrix cuadrada y en las filas subsiguientes
los valores de cada fila de la matriz separados por un espacio.