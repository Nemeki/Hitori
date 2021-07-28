#include <iostream>
#include <time.h>
#include <string>
#include <vector>
#include <sstream>
#include <cuda_runtime.h>
#include <math.h>
#include <fstream>  // Libreria para leer archivos
#include <typeinfo> // for 'typeid' to work
#include <tuple>

using namespace std;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*                             Funciones de apoyo                             */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

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
    6 -> paintable // Eliminado
*/

/*  
    Función para consistencia del Hitori
    Lo que está función hace es mirar si dos multiples
    en la misma columna o fila tienen el mismo número y si 
    ambos son not paintable (5).
*/
bool isRule4Conform(int* Hit_State, int N){
    
    int i;
    vector<tuple<int, int>> M = getRemainingMultiples(Hit_State, N);
    
    for( i = 0; i < M.size() ; i++){


    }
}

/*  
    Ejecutar cada vez que un multiplo es pintado (6)
     1. Setear todas las celdas adyacentes al múltiplo pintado.
     2. 


*/

bool StandardCyclePattern(int* Hitori, int* Hit_State, int N){




    // Comprueba Regla 4: 
    return isRule4Conform(Hit_State, N);

}

void copyHitoriToHitori(Hit_State, Hit_StateAux, N){
    int i, j;
    for(j = 0; j < N; j++)
        for( i = 0; j < N; j++)
            Hit_StateAux[i +  j*N] = Hit_State[i + j*N];
}

void setNotPaintable(int* Hit_State, tuple<int, int> tup ){
    Hit_State[ get<0>(tup) ] = 5;
}

void paint(int* Hit_State, tuple<int, int> tup){
    Hit_State[ get<0>(tup)] = 6;
    return;
}

// tuple (elem , posElem)
vector<tuple<int , int>> getRemainingMultiples(int* Hit_State, int N){
    
    int i,j;
    int elem;
    int posElem;
    vector<tuple<int, int>> M;
    tuple<int, int> tup;

    /*
        1 -> not multiple
        2 -> multiple per row
        3 -> multiple per column
        4 -> multiple per row and column
        5 -> not paintable 
        6 -> paintable // Eliminado
    */  

    for(j = 0; j < N; j++ ){
        for(i = 0; i < N; i++){
            posElem = i + j*N;
            elem = Hit_State[posElem];
            tup = make_tuple(elem,posElem);
            
            switch(elem) {
                case 2:
                    M.push_back(tup);
                    break;
                case 3:
                    M.push_back(tup);
                    break;
                case 4:
                    M.push_back(tup);
                    break;
                default:
                    break;
            }

        }
    }

    return M;
}



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

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*                                     CPU                                    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

void tripletF(int *hitori, int* estado, int N){
    int i, aux;
    bool back, next;
    for(i = 0; i < N*N; i++){
        int fila = i/N;
        int columna = i%N;
        if(columna > 0 && columna < N){
            int valor = hitori[i];
            aux = estado[i];
            back = (hitori[i-1] == valor)? true : false;
            next = (hitori[i+1] == vlaor)? true : false;
            estado[i] = (back && next)? 5 : aux;
        }
    }
}

void tripletC(int *hitori, int *estado, int N){
    int i, aux;
    bool up, down;
    for (i = 0; i < N*N; i++){
        int fila = i/N;
        int columna = i%N;
        if (fila > 0 && fila < N){
            int valor = hitori[i];
            aux = estado[i];
            up = (hitori[i-N] == valor) ? true : false;
            down = (hitori[i+N] == valor)? true : false;
            estado[i] = (up && down) ? 5 : aux;
        }
    }
}

void rescateF(int *hitori, int *estado, int N){
    int i, aux;
    bool back, next;
    for (i = 0; i < N*N; i++){
        int fila = i/N;
        int columna = i%N;
        if (columna > 0 && columna < N){
            int valor = hitori[i];
            aux = estado[i];
            back = (estado[i-1] == 6)? true : false;
            next = (estado[i+1] == 6)? true : false;
            estado[i] = (back || next) ? 5 : aux;
        }
    }
}

void rescateC(int *hitori, int *estado, int N){
    int i, aux;
    bool up, down;
    for (i = 0; i < N*N; i++){
        int fila = i/N;
        int columna = i%N;
        if (fila > 0 && fila < N){
            int valor = hitori[i];
            aux = estado[i];
            up = (estado[i-N] == 6)? true : false;
            down = (estado[i+N] == 6)? true : false;
            estado[i] = (up || down) ? 5 : aux;
        }
    }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*                         GPU primera implementacion                         */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

__global__ void kernelTripletF(int *hitori, int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool back, next;
    int aux;

    if(tId < N*N && c > 0 && c < N) {
        int valor = hitori[tId];
        aux = estado[tId];
        back = (hitori[tId-1] == valor)? true : false;
        next = (hitori[tId+1] == valor)? true : false;
        estado[tId] = (back && next) ? 5 : aux;
    }
}

__global__ void kernelTripletC(int *hitori, int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool up, down;
    int aux;

    if(tId < N*N && f > 0 && f < N) {
        int valor = hitori[tId];
        aux = estado[tId];
        up = (hitori[tId-N] == valor)? true : false;
        down = (hitori[tId+N] == valor)? true : false;
        estado[tId] = (up && down) ? 5 : aux;
    }
}

__global__ void kernelRescateF(int *hitori, int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    int back, next;
    int aux;

    if(tId < N*N && c > 0 && c < N) {
        int valor = hitori[tId];
        aux = estado[tId];
        back = (estado[tId-1] == 6)? true : false;
        next = (estado[tId+1] == 6)? true : false;
        estado[tId] = (back || next) ? 5 : aux;
    }
}


__global__ void kernelRescateC(int *hitori, int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    int up, down;
    int aux;

    if(tId < N*N && f > 0 && f < N) {
        int valor = hitori[tId];
        aux = estado[tId];
        up = (estado[tId-N] == 6)? true : false;
        down = (estado[tId+N] == 6)? true : false;
        estado[tId] = (up || down) ? 5 : aux;
    }
}


int main(int argc, char* argv[]){

    fstream FILE;  

    int* Hitori;
    int* Hit_State;
    int N;
    string line;
    vector<tuple<int, int>> M;

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

        /*
        M = getRemainingMultiples(Hit_State, N);

        for( int i = 0; i < M.size() ; i++){

            int poselem = get<1>(M[i]);
            int x = poselem%N;
            int y = poselem/N;
            
            cout << "tuple["<< i <<"] = (" << get<0>(M[i]) <<" , ["<< x << "," <<y <<"] ) " << endl;

        }
        */

        // Parte 1: Ejecutarse Standard Patterns
        /*
        showMatrix(Hitori, N, N);

        printf("\n");
        */

        showMatrix(Hit_State, N, N);
        


        // Parte 2: 
        
        vector<tuple> M; 
        bool flag = false;
        bool inconst;
        int* hitaux;
        int* Hit_StateCpy = new int[N*N];
        
        while(!flag){
            flag = true;
            for( i = 0; i < M.size(); i++ ){
                paint(Hit_State, M[i]);
                // Copia del estado inicial
                copyHitoriToHitori(Hit_State, Hit_StateAux, N);

                inconst = StandardCyclePattern(Hitori, Hit_State, N);

                if( inconst ){
                    
                    // Volver la matrix al estado inicial
                    hit_aux = Hit_State;
                    Hit_State = Hit_StateAux;
                    Hit_StateAux = hit_aux;

                    setNotPaintable(Hitori, Hit_State, N);
                    
                    StandardCyclePattern(Hitori, Hit_State, N);

                    M = getRemainingMultiples(Hit_State, N);

                    flag = false;
                    
                    break; // seteo i = 0

                }

                

            }




        }
        





    }

    FILE.close();



    return 0;
}