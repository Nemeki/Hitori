#include <iostream>
#include <time.h>
#include <string>
#include <vector>
#include <sstream>
#include <cuda_runtime.h>
#include <math.h>
#include <fstream>  // Libreria para leer archivos
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
    		printf("%d ", matrix[i + j*N]);
    	printf("\n");
    }
    printf("\n");
}

void readHitoriFromFile(fstream* FILE, int* matrixH, int N){

    int i, j = 0;

    const char delim = ' ';

    string line;
    vector<string> row;
    
    while( getline(*FILE, line)){

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

void setInitialHitoriState(int *Hit_State, int N) {

    for(int j = 0; j < N; j++)
    	for(int i = 0; i < N; i++)
    		Hit_State[i + j*N] = 1;    // 1 -> not multiple
    
}

void SetHitoriState( int* Hitori, int* Hit_State, int N){
    bool flag1, flag2;

    for(int j = 0; j < N; j++){
    	for(int i = 0; i < N; i++){
            
            flag1 = false; flag2 = false;
            
            int posElem = i + j*N;
            int elem = Hitori[posElem];
            
            // iterar por Fila
            for(int k = j*N;  k < N + j*N ; k++){

                if( k == posElem )
                    continue;

                if( Hitori[k] == elem ){ 
                    flag1 = true;
                    break;
                }    
            }
       
            // iterar por Columna
            for(int t = i; t < N*N ;t += N ){

                if( t == posElem )
                    continue;
                
                if( Hitori[t] == elem){
                    flag2 = true;
                    break;
                }

            }

            if( flag1 == true && flag2 == true) // case 4 -> multiple per row and column
                Hit_State[posElem] = 4;
            else if( flag1 == true )           //2 -> multiple per row 
                Hit_State[posElem] = 2;          
            else if( flag2 == true)            //3 -> multiple per column
                Hit_State[posElem] = 3;  
            
        
        }

    }


}


int main(int argc, char* argv[]){

    fstream FILE;  

    int* Hitori;
    int* Hit_State;
    int N;
    string line;

    string nameFile = argv[1];
    // Abrir el archivo en modo lectura
    
    FILE.open(nameFile, ios::in);

    if(!FILE){
        cerr << "Unable to open file!" << endl;
        exit(1);
    }

    if( FILE.is_open() ){

        getline(FILE, line);
        
        N = stoi(line);

        Hitori = new int[N*N];
        Hit_State = new int[N*N];

        setInitialHitoriState(Hit_State, N);

        readHitoriFromFile(&FILE, Hitori, N);

        SetHitoriState( Hitori, Hit_State, N);

        // Ejecutarse Standard Patterns
        showMatrix(Hitori, N, N);

        printf("\n");

        showMatrix(Hit_State, N, N);


    }

    FILE.close();

    return 0;
}