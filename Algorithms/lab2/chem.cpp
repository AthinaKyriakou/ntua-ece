#include <iostream>
#include <time.h>
#include <fstream>  
#include <limits.h>

using namespace std; 

int main (int argc, char **argv) {

	//to read from file
	ifstream infile;
	infile.open(argv[1]);
	//clock_t tStart = clock();

	//read input
	long int N, K;
	scanf("%ld", &N);
	scanf("%ld", &K);
	//infile >> N >> K;

    //read and calculate cumulative sums
    long int cumSums[N+1][N+1];
    for(long int i = 0; i <= N; i++){
    	for(long int j = 0; j <= N; j++){
    		cumSums[i][j] = 0;
    	}
    }

    long int prev = 0;
    for (long int i = 1; i < N; i++) {
    	prev = 0;
    	for(long int j = i+1; j <= N; j++){
    		long int t;
    		scanf("%ld", &t); 
    		//infile >> t; 
    		cumSums[i][j] = prev + t;
    		prev = cumSums[i][j];
    	}
    }

    // K bottles + N substances
    long int minEnergy[K+1][N+1];
    for(long int l = 0; l < K+1; l++){
    	for(long int i = 0; i < N+1; i++){
    		minEnergy[l][i] = 0;
    	}
    }

    // fill the line when I have one bottle
    for(long int i = 1; i <= N; i++){
    	for(long int j = i; j >= 1; j--){
    		minEnergy[1][i] += cumSums[j][i];
    	}
    }

    for(long int l = 2; l <= K; l++){
    	
    	for(long int i = 1; i <= N; i++){
    		
    		long int res = LONG_MAX;
    		long int prev = 0;

    		for(long int j = i-1; j >= 0; j--){
    			prev +=  cumSums[j+1][i];

    			long int tmp = minEnergy[l-1][j] + prev;
    			if(tmp < res){
    				res = tmp;
    			}
    		}
    		minEnergy[l][i] = res;
    	}
    }

    cout << minEnergy[K][N] << endl;

    //printf("Time taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    return 0;
}