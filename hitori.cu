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

__constant__ int HitoriCM[5*5];  //FIXME: Cambiar cuando se actualice N y M

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

void showMatrix(string* matrix, int N, int M) {
    for(int j = 0; j < M; j++){
    	for(int i = 0; i < N; i++)
            cout << matrix[i + j*N] << " ";
    	printf("\n");
    }
    printf("\n");
}


void readHitoriFromFile(fstream* FILE, int* matrixH, string* matrixHstr, int N){

    int i, j = 0;

    const char delim = ' ';

    string line;
    vector<string> row;
    
    while( getline(*FILE, line)){

        tokenize(line, delim, row);

        for(i = 0; i < N ; i++){
            matrixHstr[j] = row[i];
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

    return true;
}

/*  
    Ejecutar cada vez que un multiplo es pintado (6)
     1. Setear todas las celdas adyacentes al múltiplo pintado.
     2. 


*/

bool StandardCyclePattern(int* Hitori, int* Hit_State, int N){

    // Comprueba Regla 4: 
    // return isRule4Conform(Hit_State, N);

    return true;

}

void copyHitoriToHitori(int* Hit_State, int* Hit_StateAux, int N){
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

void updateHitori(string* Hitori_Str, int* Hit_State, int N){
    int i, j;

    for( j = 0; j < N; j++){
        for( i = 0; i < N; i++){
            if( Hit_State[i + j*N] == 6)
                Hitori_Str[i + j*N] = "X";
        }
    }
    return;
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
            next = (hitori[i+1] == valor)? true : false;
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

void DobleC(int* hitori,int *estado, int N){

    int f; //Fila en que esta
	int c; //Columna en la que esta
    bool ant = false;
    bool doble = false;
    int pos;

    for(int i = 0; i < N*N; i++) {
        f = i / N;
        c = i % N;
        int valor = hitori[i];
        for(int j = 0; j < N; j++){
            pos = c+N*j;
            doble = (ant && i != pos && hitori[pos] == valor)? true : doble;
            ant = (i != pos && hitori[pos] == valor)? true : false;
        }
        if(doble) {
            estado[i] = 6;
        }
    }

}

void DobleF(int* hitori,int *estado, int N){
    
    int f; //Fila en que esta
	int c; //Columna en la que esta
    bool ant = false;
    bool doble = false;
    int pos;

    for(int i = 0; i < N*N; i++) {
        f = i / N;
        c = i % N;
        int valor = hitori[i];
        for(int j = 0; j < N; j++){
            pos = f+j;
            doble = (ant && i != pos && hitori[pos] == valor)? true : doble;
            ant = (i != pos && hitori[pos] == valor)? true : false;
        }
        if(doble) {
            estado[i] = 6;
        }
    }
}

void muerteF(int *hitori, int *estado, int N){
    int i, aux1, aux2;
    for(i = 0; i < N*N; i++){
        int fila = i/N;
        int columna = i%N;
        int valor = hitori[i];
        aux1 = estado[i];
        if(aux1 != 5 && aux1 !=6){
            for(int j = 0; j < N; j++){
                aux2 = hitori[fila + j];
                if(valor == aux2) aux1 = (estado[fila+j] == 5)? 6 : aux1;
            }
        }
    }
}

void muerteC(int *hitori, int *estado, int N){
    int i, aux1, aux2;
    for(i = 0; i < N*N; i++){
        int fila = i/N;
        int columna = i%N;
        int valor = hitori[i];
        aux1 = estado[i];
        if(aux1 != 5 && aux1 !=6){
            for(int j = 0; j < N; j++){
                aux2 = hitori[columna + N*j];
                if(valor == aux2) aux1 = (estado[columna + N*j] == 5)? 6 : aux1;
            }
        }
    }
}

void funcionCPU(int* Hitori, int* estado, int N){

    int i;
    // Ejecutar patrones 
    tripletF(Hitori, estado, N);
    tripletC(Hitori, estado, N);
    //DobleF(Hitori, estado, N);
    //DobleC(Hitori, estado, N);
 
    for(i = 0; i < 10; i++){
        muerteF(Hitori, estado, N);
        muerteC(Hitori, estado, N);
        rescateC(Hitori, estado, N);
        rescateF(Hitori, estado, N);
    }

    return;

}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*                         GPU primera implementacion                         */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/* -------------------------- Deteccion de patrones ------------------------- */

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

__global__ void kernelDobleF(int *hitori, int *estado, int N){
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool ant = false;
    bool doble = false;
    int pos;

    if(tId < N*N) {
        int valor = hitori[tId];
        for(int i = 0; i < N; i++){
            pos = f+i;
            doble = (ant && tId != pos && hitori[pos] == valor)? true : doble;
            ant = (tId != pos && hitori[pos] == valor)? true : false;
        }
        if(doble) {
            estado[tId] = 6;
        }
    }
}

__global__ void kernelDobleC(int *hitori, int *estado, int N){
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool ant = false;
    bool doble = false;
    int pos;

    if(tId < N*N) {
        int valor = hitori[tId];
        for(int i = 0; i < N; i++){
            pos = c+N*i;
            doble = (ant && tId != pos && hitori[pos] == valor)? true : doble;
            ant = (tId != pos && hitori[pos] == valor)? true : false;
        }
        if(doble) {
            estado[tId] = 6;
        }
    }
}

/* ---------------------------- Funciones del for --------------------------- */

__global__ void kernelRescateF(int *hitori, int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool back, next;
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
    bool up, down;
    int aux;

    if(tId < N*N && f > 0 && f < N) {
        int valor = hitori[tId];
        aux = estado[tId];
        up = (estado[tId-N] == 6)? true : false;
        down = (estado[tId+N] == 6)? true : false;
        estado[tId] = (up || down) ? 5 : aux;
    }
}

__global__ void kernelMuerteF(int *hitori, int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    int aux1, aux2, aux3;

    if(tId < N*N) {
        int valor = hitori[tId];
        aux1 = estado[tId];
        if(aux1 != 5 && aux1 != 6){
            for(int i = 0; i < N; i++){
                aux2 = hitori[f+i];
                if(valor == aux2){
                    aux1 = (estado[f+i] == 5)? 6 : aux1;
                }
            }
            estado[tId] = aux1;
        }
    }

}

__global__ void kernelMuerteC(int *hitori, int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    int aux1, aux2, aux3;

    if(tId < N*N) {
        int valor = hitori[tId];
        aux1 = estado[tId];
        if (aux1 != 5 && aux1 != 6){
            for(int i = 0; i < N; i++){
                aux2 = hitori[c+N*i];
                if(valor == aux2){
                    aux1 = (estado[c+N*i] == 5)? 6 : aux1;
                }
            }
            estado[tId] = aux1;
        }
    }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*                         GPU segunda implementacion                         */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

__global__ void kernelTripletF_CM(int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool back, next;
    int aux;

    if(tId < N*N && c > 0 && c < N) {
        int valor = HitoriCM[tId];
        aux = estado[tId];
        back = (HitoriCM[tId-1] == valor)? true : false;
        next = (HitoriCM[tId+1] == valor)? true : false;
        estado[tId] = (back && next) ? 5 : aux;
    }

}

__global__ void kernelTripletC_CM(int *estado, int N){

    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool up, down;
    int aux;

    if(tId < N*N && f > 0 && f < N) {
        int valor = HitoriCM[tId];
        aux = estado[tId];
        up = (HitoriCM[tId-N] == valor)? true : false;
        down = (HitoriCM[tId+N] == valor)? true : false;
        estado[tId] = (up && down) ? 5 : aux;
    }

}

__global__ void kernelRescateF_CM(int *estado, int N){

    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool back, next;
    int aux;

    if(tId < N*N && c > 0 && c < N) {
        int valor = HitoriCM[tId];
        aux = estado[tId];
        back = (estado[tId-1] == 6)? true : false;
        next = (estado[tId+1] == 6)? true : false;
        estado[tId] = (back || next) ? 5 : aux;
    }

}

__global__ void kernelRescateC_CM(int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool up, down;
    int aux;

    if(tId < N*N && f > 0 && f < N) {
        int valor = HitoriCM[tId];
        aux = estado[tId];
        up = (estado[tId-N] == 6)? true : false;
        down = (estado[tId+N] == 6)? true : false;
        estado[tId] = (up || down) ? 5 : aux;
    }
}

__global__ void kernelDobleC_CM(int *estado, int N){
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool ant = false;
    bool doble = false;
    int pos;

    if(tId < N*N) {
        int valor = HitoriCM[tId];
        for(int i = 0; i < N; i++){
            pos = c+N*i;
            doble = (ant && tId != pos && HitoriCM[pos] == valor)? true : doble;
            ant = (tId != pos && HitoriCM[pos] == valor)? true : false;
        }
        if(doble) {
            estado[tId] = 6;
        }
    }
}

__global__ void kernelDobleF_CM(int *estado, int N){
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    bool ant = false;
    bool doble = false;
    int pos;

    if(tId < N*N) {
        int valor = HitoriCM[tId];
        for(int i = 0; i < N; i++){
            pos = f+i;
            doble = (ant && tId != pos && HitoriCM[pos] == valor)? true : doble;
            ant = (tId != pos && HitoriCM[pos] == valor)? true : false;
        }
        if(doble) {
            estado[tId] = 6;
        }
    }
}

__global__ void kernelMuerteF_CM(int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    int aux1, aux2, aux3;

    if(tId < N*N) {
        int valor = HitoriCM[tId];
        aux1 = estado[tId];
        if(aux1 != 5 && aux1 != 6){
            for(int i = 0; i < N; i++){
                aux2 = HitoriCM[f+i];
                if(valor == aux2){
                    aux1 = (estado[f+i] == 5)? 6 : aux1;
                }
            }
            estado[tId] = aux1;
        }
    }

}

__global__ void kernelMuerteC_CM(int *estado, int N){
	
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    int f = tId / N; //Fila en que esta
	int c = tId % N; //Columna en la que esta
    int aux1, aux2, aux3;

    if(tId < N*N) {
        int valor = HitoriCM[tId];
        aux1 = estado[tId];
        if (aux1 != 5 && aux1 != 6){
            for(int i = 0; i < N; i++){
                aux2 = HitoriCM[c+N*i];
                if(valor == aux2){
                    aux1 = (estado[c+N*i] == 5)? 6 : aux1;
                }
            }
            estado[tId] = aux1;
        }
    }
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*                                    Main                                    */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

int main(int argc, char* argv[]){

    fstream FILE;  

    int* Hitori;
    string* Hitori_Str;
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
        Hitori_Str = new string[N*N];

        setInitialHitoriState(Hit_State, N);

        readHitoriFromFile(&FILE, Hitori, Hitori_Str, N);

        SetHitoriState( Hitori, Hit_State, N);

        // Parte CPU
        // Inicialización variables de tiempo
        clock_t t1, t2;
        double ms; 

        t1 = clock();
        funcionCPU(Hitori, Hit_State, N);
        t2 = clock();
        ms = 1000.0 * (double)(t2 - t1) / CLOCKS_PER_SEC;   
        printf("Tiempo de CPU: %5f \n", ms);
        //cout << "Tiempo CPU: " << ms << "[ms]" << endl;

                     
        // Visualizar Hitori
        updateHitori(Hitori_Str, Hit_State, N);
        showMatrix(Hitori_Str, N, N);
        printf("\n Hitori Estado \n");
        showMatrix(Hit_State, N, N); 

        SetHitoriState( Hitori, Hit_State, N);

        // Parte GPU 1 
        // Def tiempos GPU
        int* HitoriDev, *Hit_StateDev;
        cudaEvent_t ct1, ct2;
        float dt;
        cudaEventCreate(&ct1);
        cudaEventCreate(&ct2);

        int block_size = 256;					 		              // múltiplo de 32
        int grid_size  = (int)ceil((float)(N*N)/block_size);          // ceil : función techo 

        cudaMalloc(&HitoriDev, sizeof(int)*N*N);
        cudaMalloc(&Hit_StateDev, sizeof(int)*N*N);

        cudaEventCreate(&ct1);
        cudaEventCreate(&ct2);
        cudaEventRecord(ct1);
        cudaMemcpy(HitoriDev, Hitori, N*N*sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(Hit_StateDev, Hit_State, N*N*sizeof(int), cudaMemcpyHostToDevice);
        kernelTripletF<<<grid_size, block_size>>>(HitoriDev, Hit_StateDev, N);
        kernelTripletC<<<grid_size, block_size>>>(HitoriDev, Hit_StateDev, N);
        //kernelDobleF<<<grid_size, block_size>>>(HitoriDev, Hit_StateDev, N);
        //kernelDobleC<<<grid_size, block_size>>>(HitoriDev, Hit_StateDev, N);
        for(int i = 0; i < 10; i++){
            kernelMuerteF<<<grid_size, block_size>>>(HitoriDev, Hit_StateDev, N);
            kernelMuerteC<<<grid_size, block_size>>>(HitoriDev, Hit_StateDev, N);
            kernelRescateF<<<grid_size, block_size>>>(HitoriDev, Hit_StateDev, N);
            kernelRescateC<<<grid_size, block_size>>>(HitoriDev, Hit_StateDev, N);
        }
        cudaMemcpy(Hit_State, Hit_StateDev, N*N*sizeof(int), cudaMemcpyDeviceToHost);
        cudaEventRecord(ct2);
        cudaEventSynchronize(ct2);
        cudaEventElapsedTime(&dt, ct1, ct2);

        cout << "Tiempo GPU 1: " << dt << "[ms]" << endl;

                
        // Visualizar Hitori
        updateHitori(Hitori_Str, Hit_State, N);
        showMatrix(Hitori_Str, N, N);
        printf("\n Hitori Estado \n");
        showMatrix(Hit_State, N, N); 


        SetHitoriState( Hitori, Hit_State, N);

        // Parte GPU 2
        int* Hit_StateDev2;
        cudaMalloc(&Hit_StateDev2, sizeof(int)*N*N);
    
        cudaEventRecord(ct1);
        cudaMemcpyToSymbol(HitoriCM, Hitori, N*N*sizeof(int), 0, cudaMemcpyHostToDevice); // Para kernel CM
        cudaMemcpy(Hit_StateDev2, Hit_State, N*N*sizeof(int), cudaMemcpyHostToDevice);
        kernelTripletF_CM<<<grid_size, block_size>>>(Hit_StateDev2, N);
        kernelTripletC_CM<<<grid_size, block_size>>>(Hit_StateDev2, N);
        //kernelDobleF_CM<<<grid_size, block_size>>>(Hit_StateDev2, N);
        //kernelDobleC_CM<<<grid_size, block_size>>>(Hit_StateDev2, N);
        for(int i = 0; i < 10; i++){
            kernelMuerteF_CM<<<grid_size, block_size>>>(Hit_StateDev2, N);
            kernelMuerteC_CM<<<grid_size, block_size>>>(Hit_StateDev2, N);
            kernelRescateF_CM<<<grid_size, block_size>>>(Hit_StateDev2, N);
            kernelRescateC_CM<<<grid_size, block_size>>>(Hit_StateDev2, N);
        }
        cudaMemcpy(Hit_State, Hit_StateDev2, N*N*sizeof(int), cudaMemcpyDeviceToHost);
        cudaEventRecord(ct2);
        cudaEventSynchronize(ct2);
        cudaEventElapsedTime(&dt, ct1, ct2);


        cout << "Tiempo GPU 2: " << dt << "[ms]" << endl;
                     
        // Visualizar Hitori
        updateHitori(Hitori_Str, Hit_State, N);
        showMatrix(Hitori_Str, N, N);
        printf("\n Hitori Estado \n");
        showMatrix(Hit_State, N, N); 

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
    
        
        // Parte 2: 
        
        /*
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
        */

    }

    FILE.close();



    return 0;
}