#include <iostream>
#include <algorithm>
#include <vector>
#include <time.h>
#include <fstream>  

using namespace std; 


struct Car {
  long int cost;
  long int capacity;
};

bool car_sorter(Car const &lhs, Car const &rhs) {
    return lhs.capacity < rhs.capacity;
}

//check if a car serves the distance + time constraints
//stationDist are sorted in ascending order, distances are not unique, avoid double checking
bool is_possible(long int carCapacity, long int K, long int D, long int stationDist[], long int T, long int Ts, long int Cs, long int Tf, long int Cf){

	long int totalTime = 0;
	long int coveredDist = 0;
	long int prevStatDist = -1;

	for(long int i = 0; i < K; i++){
		if(stationDist[i] != prevStatDist){
			long int d = stationDist[i] - coveredDist;
			long int maxFastDist;
			long int m = (carCapacity-d*Cs)/(Cf-Cs);
			if (m < 0){
				return false;
			}
			maxFastDist = min(d,m);		
			long int t = d*Ts-maxFastDist*(Ts-Tf);
			totalTime += t;
			if(totalTime > T){
				return false;
			}
			coveredDist += d;
		}
	}
	
	long int d = D - coveredDist;
	long int maxFastDist;
	long int m = (carCapacity-d*Cs)/(Cf-Cs);
	if (m < 0){
		return false;
	}
	maxFastDist = min(d,m);		
	long int t = d*Ts-maxFastDist*(Ts-Tf);
	totalTime += t;
	if(totalTime > T){
		return false;
	}
	return true;
}

//SOS: not directly binary search to the answer!!
//find the smaller car capacity that solves the problem
//cars sorted by capacity
long int binary_search(vector<Car> cars, long int N, long int K, long int D, long int stationDist[], long int T, long int Ts, long int Cs, long int Tf, long int Cf){

	long int start = 0;
	long int end = N-1;
	long int minCapacityPos = -1;

	while(start <= end){
		long int mid = (start + end) / 2;
		Car midCar = cars[mid];
		if(is_possible(midCar.capacity, K, D, stationDist, T, Ts, Cs, Tf, Cf)){
			minCapacityPos = mid;
			end = mid - 1;
		} else {
			start = mid + 1;
		}
	}
	return minCapacityPos;
}

int main (int argc, char **argv) {

	//to read from file
	//ifstream infile;
	//infile.open(argv[1]);
	//clock_t tStart = clock();

	//read input
	long int N, K, D, T;
	scanf("%ld", &N);
	scanf("%ld", &K);
	scanf("%ld", &D);
	scanf("%ld", &T);
	//infile >> N >> K >> D >> T;

    //read cars 
    vector<Car> cars;
    for (long int i = 0; i < N; i++) { 
    	Car tmp;
    	long int cost, capacity;
    	scanf("%ld", &cost);
    	scanf("%ld", &capacity);
    	tmp.cost = cost;
    	tmp.capacity = capacity;
    	//infile >> tmp.cost >> tmp.capacity;
        cars.push_back(tmp);   
    }

    //read gas station distances from beginning
    long int stationDist[K];
    for (long int i = 0; i < K ; i++) { 
    	scanf("%ld", &stationDist[i]);
    	//infile >> stationDist[i]; 
    }  

    //read Ts, Cs, Tf, Cf
    long int Ts, Cs, Tf, Cf;
    scanf("%ld", &Ts);
	scanf("%ld", &Cs);
	scanf("%ld", &Tf);
	scanf("%ld", &Cf);
	//infile >> Ts >> Cs >> Tf >> Cf;

	//sort cars in ascending capacity order --> O(N*log(N)) 
    sort(cars.begin(), cars.end(),&car_sorter);

    //sort station distamces in ascending order --> O(k*log(K))
    sort(stationDist, stationDist + sizeof(stationDist)/sizeof(stationDist[0]));

	//binary search on the cars capacity to find the min possible --> O(log(N)*T(is_answer))
	long int minCapacityPos = binary_search(cars, N, K, D, stationDist, T, Ts, Cs, Tf, Cf);

	//linear search on the cars from minCapacityPos to (N-1) to find the minCost
	long int minCost = -1;
	if(minCapacityPos > -1){
		minCost = cars[N-1].cost;
		for(long int i = minCapacityPos; i < N-1; i++){
			if(cars[i].cost < minCost)
				minCost = cars[i].cost;
		}
	}

	cout << minCost << endl;

    //printf("\nTime taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    return 0;
}
