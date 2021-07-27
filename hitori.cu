#include <iostream>
#include <stdio.h>
#include <time.h>
#include <string>
#include <vector>
#include <sstream>
#include <cuda_runtime.h>
#include <math.h>
#include <fstream> // Libreria para leer archivos

#include <typeinfo> // for 'typeid' to work

using namespace std;

// Función para Splitear un String
void tokenize(string const &str, const char delim, vector<string> &out) {
    // construct a stream from the string
    stringstream ss(str);
    string s;

    while (getline(ss, s, delim)) {
        out.push_back(s);
    }

    return;

}

/*
 *  Impresor de Matrix 2D - Almacenada linealmente
 */
void showMatrix(int *matrix, int N, int M) {
    for(int j = 0; j < M; j++){
    	for(int i = 0; i < N; i++)
    		printf("%d", matrix[i + j*N]);
    	printf("\n");
    }
    printf("\n");
}

void readHitoriFromFile(fstream* FILE, float* matrixH, int N){

    int i, j = 0;

    const char delim = ' ';

    string line;
    vector<string> row;
    
    while( getline(*FILE. line)){

        tokenize(line, delim, row);

        for(i = 0; i < N ; i++){
            matrixH[j++] = stoi(row[i]);
        }
        // Limpiar el buffer de salida  
        row.clear();
    }

}

/*
    1 -> not multiple
    2 -> multiple per row
    3 -> multiple per column
    4 -> multiple per row and column
    5 -> not paintable
    6 -> paintable
*/

void checkColAndRow(){




}


void SetHitoriState( int* Hitori, int* Hit_State, int N){

    for(int j = 0; j < N; j++){
    	for(int i = 0; i < N; i++){
            
            int elem = matrix[i + j*N];

            if( elem != 0 )
                // iterar por Fila
                for(int k = 0 + j*N;  k <  ; k++){
                    if(   )



                }
                // iterar por Columna



            else
                continue;

            
        } printf("%d", matrix[i + j*N]);
    }


}



int main(int argc, char* argv[]){

    ifstream FILE;  

    int Hitori;
    int Hit_State;
    int N;
    string line;

    // Abrir el archivo en modo lectura
    
    FILE.open(argv[1], ios::in);

    if(!FILE){
        cerr << "Unable to open file!" << endl;
        exit(1);
    }

    if( FILE.is_open() ){

        getline(FILE, line);
        
        N = stoi(line[0]);

        Hitori = new int[N*N];
        Hit_State = new int[N*N];

        readHitoriFromFile(&FILE, Hitori, N);

        // Ejecutarse Standard Patterns


    }

    FILE.close();

    return 0;
}