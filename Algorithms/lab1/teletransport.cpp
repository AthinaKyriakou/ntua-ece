#include <iostream>
#include <algorithm>
#include <vector>
#include <time.h>
#include <fstream>  

using namespace std; 

struct Portal {
  long int v1;
  long int v2;
  long int width;
};


bool portal_sorter(Portal const &lhs, Portal const &rhs) {
    return lhs.width < rhs.width;
}


// union-find operations

//returns the representative of the set, implemented with path compression --> amortized O(1)
//changes the parent table
long int find_op(long int x, vector<vector<long int>> &parentTable){

	//x is not the representative of the class
	if(x != parentTable[0][x]){
		parentTable[0][x] = find_op(parentTable[0][x], parentTable);
	} 
	return parentTable[0][x];
}

//changes the parent table
void union_op(long int s1, long int s2, vector<vector<long int>> &parentTable){
	
	// find the representative of each set
	long int a = find_op(s1, parentTable);
	long int b = find_op(s2, parentTable);

	if (a == b){
		//printf("\nSame representative - no change\n");
		return;
	}

	// attach the tree with the smaller rank to the one with the larger rank
	if(parentTable[1][a] < parentTable[1][b]){
		parentTable[0][a] = b;
		parentTable[1][b] += parentTable[1][a];
	} else {
		parentTable[0][b] = a;
		parentTable[1][a] += parentTable[1][b];
	}

}

// creates a minimum spanning tree
vector<vector<long int>> createParentTable(long int universeTransfers[], long int N, long int pos, vector<Portal> portals){

	//parentTable[0][i]: the parent of node i
	//parentTable[1][i]: if parentTable[0][i] == -1, the size of the set with representative the node i
	vector<vector<long int>> parentTable(2, vector<long int>(N)); 

	//mark all nodes as separate subsets with only 1 element
    for (long int i = 0; i < N; i++){
            parentTable[0][i] = i;
            parentTable[1][i] = 1;
    }

	//unify the subsets that are connected by one of the permitted portals --> O(m)
	for (long int i = pos; i < portals.size(); i++){
		Portal tmp = portals.at(i);
		union_op(tmp.v1, tmp.v2, parentTable);
	}

	return parentTable;
}


//check connected components: 
//if every element that is not in the right position is in the same connected component as the position where it should be 
//then the array of universe transfers can be sorted
bool is_possible(long int pos, vector<Portal> portals, long int universeTransfers[], long int N){
	
	//create parent table with permitted portals --> O(M) since union in O(1)
	vector<vector<long int>> parentTable = createParentTable(universeTransfers, N, pos, portals);

	//check connected components --> O(N) since find in O(1)
	for(long int i = 0; i < N; i++){
		
		//if the element is not in the right poision
		if(i != universeTransfers[i]){

			//if they do not belong to the same connected component
			if(find_op(i, parentTable) != find_op(universeTransfers[i], parentTable)){
				return false;
			}
		}
	}

	return true;
}

//maximize the width of the portal with the min width
long int binary_search(vector<Portal> portals, long int M, long int universeTransfers[], long int N){

	long int start = 0;
	long int end = M-1;
	long int maxMinWidth = 0;
	
	while (start <= end) { 
		long int mid = (start + end) / 2;
		Portal midPortal = portals[mid];
        //if the array of universe transfers can be sorted by using portals with width >= midPortal.width
        //binary search to the right of the array to check if I can use wider portals
        if (is_possible(mid, portals, universeTransfers, N)){
        	maxMinWidth = midPortal.width;
        	start = mid + 1;
        } else {
        	end = mid - 1;
        }
    }
    
    return maxMinWidth;
}

int main (int argc, char **argv) {

	//to read from file
	//ifstream infile;
	//infile.open(argv[1]);
	//clock_t tStart = clock();

	//read input
	long int N, M;
	scanf("%ld", &N);
	scanf("%ld", &M);
	//infile >> N >> M;
    
    long int universeTransfers[N];
    vector<Portal> portals;

    //read universe transfers   
    for (long int i = 0; i < N ; i++) { 
    	long int tmp;
    	scanf("%ld", &tmp);
    	//infile >> tmp; 
    	universeTransfers[i] = tmp - 1;  
    }  

    //read portals 
    for (long int i = 0; i < M; i++) { 
    	Portal tmp;
    	long int t1, t2, t3;
    	scanf("%ld", &t1);
    	scanf("%ld", &t2);
    	scanf("%ld", &tmp.width);
    	//infile >> t1 >> t2 >> t3;
    	tmp.v1 = t1 - 1;
    	tmp.v2 = t2 - 1;
    	//tmp.width = t3;
        portals.push_back(tmp);   
    }

    //sort panels in ascending width order --> O(M*log(M)) 
    sort(portals.begin(), portals.end(),&portal_sorter);

    //binary search in the answer --> O(log(M)*T(is_answer))
    long int maxMinWidth = binary_search(portals, M, universeTransfers, N);

    //printf("\nTime taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);

    cout << maxMinWidth << endl;
    return 0;
}