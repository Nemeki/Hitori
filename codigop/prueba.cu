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

// tuple (elem , posElem)
vector<tuple<int , int>> getRemainingMultiples(int* Hit_State,int N){
    
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

    for(i = 0; i < N; i++ ){
        for(j = 0; j < N; j++){
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


int main( ){

    tuple<int, int> tup1, tup2;

    tup1 = make_tuple(1,3);

    tup2 = make_tuple(1,5);

    vector<tuple<int, int>> M;
    
    M.push_back(tup1);
    M.push_back(tup2);

    /*
    for( int i = 0; i < M.size() ; i++){
        
        cout << "tuple["<< i <<"] = (" << get<0>(M[i]) <<" ," << get<1>(M[i]) << ") " << endl;

    }
    */
    int N = 10;
    string* Hitori = new string[N*N];

    Hitori[0] = "dsadadasdas";

    cout << "EL VALOR DE GIROTIRO : "<< Hitori[0] << endl;


    return 0;

}