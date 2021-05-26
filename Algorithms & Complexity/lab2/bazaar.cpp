#include <iostream>
#include <time.h>
#include <fstream>  
#include <vector>
#include <algorithm>

using namespace std; 

struct Packet {
  int quantity;
  int cost;
};

void print_vector(vector<Packet> v, int seller, int item){
	cout << "Vector: " << seller << ", " << item << "\n";
	for(int i = 0; i < v.size(); i++){
		Packet p = v.at(i);
		cout << "Packet " << i << ": quantity: " << p.quantity << ", cost: " << p.cost << "\n";
	}
}


void min_cost_item(vector<int> &min_cost, vector<Packet> v, int N){
	
	// total quantity that the seller can provide for this item
	int total_quantity = 0;
	for(int i = 0; i < v.size(); i++){
		total_quantity += v.at(i).quantity;
	}

	// initialization of min_cost vector
	min_cost.resize(min(total_quantity, N) + 1);
	min_cost[0] = 0;
	for(int i = 1; i < min_cost.size(); i++)
		min_cost[i] = 1+1e9;

	// knapsack implementation; min_cost[k]: the min_cost to get k items of this type from this seller
	int cur_quantity = 0;
	for(int i = 0; i < v.size(); i++){
		Packet p = v.at(i);
		int quantity = p.quantity;
		int cost = p.cost;
		cur_quantity += quantity;

		for(int j = min(N, cur_quantity); j >= 0; j--){
			int prev = max(j-quantity, 0);
			min_cost[j] = min(cost + min_cost[prev], min_cost[j]);
		}
	}
}

void min_cost_set(vector<int> &min_cost, vector<int> min_cost_item_A, vector<int> min_cost_item_B, vector<int> min_cost_item_C){
	int res_size = min((int) min_cost_item_A.size(), (int) min_cost_item_B.size());
	res_size = min(res_size, (int) min_cost_item_C.size());
	
	for(int i = 0; i < res_size; i++){
		int tmp = min_cost_item_A.at(i) + min_cost_item_B.at(i) + min_cost_item_C.at(i);
		min_cost.push_back(tmp);
	}
}

int main (int argc, char **argv) {

	//to read from file
	//ifstream infile;
	//infile.open(argv[1]);
	//clock_t tStart = clock();

	//read input
	int N, M;
	scanf("%d", &N);
	scanf("%d", &M);
	//infile >> N >> M;

	vector<Packet> vectors[3][3];
	int seller, item, quantity, cost;
	char tmp;
	for(int i = 0; i < M; i++){
		scanf("%d", &seller);
		seller = seller - 1;
		scanf("%c", &tmp);
		item = tmp - 'A';
		Packet cur;
		scanf("%d", &cur.quantity);
		scanf("%d", &cur.cost);
		vectors[seller][item].push_back(cur);
	}

	// min_cost_item: min cost per quantity of items (for each seller and type of product)
	// min_cost_set: min cost per set of (A, B, C) items (for each seller)

	vector<int> min_cost_item_A, min_cost_item_B, min_cost_item_C;
	vector<int> seller1, seller2, seller3;

	// for seller 1
	min_cost_item(min_cost_item_A, vectors[0][0], N);
	min_cost_item(min_cost_item_B, vectors[0][1], N);
	min_cost_item(min_cost_item_C, vectors[0][2], N);
	min_cost_set(seller1, min_cost_item_A, min_cost_item_B, min_cost_item_C);

	// for seller 2
	min_cost_item(min_cost_item_A, vectors[1][0], N);
	min_cost_item(min_cost_item_B, vectors[1][1], N);
	min_cost_item(min_cost_item_C, vectors[1][2], N);
	min_cost_set(seller2, min_cost_item_A, min_cost_item_B, min_cost_item_C);
	
	// for seller 3
	min_cost_item(min_cost_item_A, vectors[2][0], N);
	min_cost_item(min_cost_item_B, vectors[2][1], N);
	min_cost_item(min_cost_item_C, vectors[2][2], N);
	min_cost_set(seller3, min_cost_item_A, min_cost_item_B, min_cost_item_C);


	// find best combination if exists
	int result = 1+1e9;

	if(seller1.size() + seller2.size() + seller3.size() - 3 < N){
		cout << "-1" << endl;
		
	} else {
		int s1 = min((int) seller1.size()-1, N);
		
		for(int i = 0; i <= s1; i++){
			int s2 = min((int) seller2.size()-1, N-i);
			
			for(int j = 0; j <= s2; j++){
				int s3 = seller3.size() - 1;
				
				if(i+j+s3 >= N){
					int new_res = seller1.at(i) + seller2.at(j) + seller3.at(N-i-j);
					result = min(result, new_res);
				}
			}
		} 

		cout << result << endl;
	}

	/*for(int i = 0; i < seller1.size(); i++){
		cout << seller1.at(i) << ", ";
	}
	cout << "\n";

	for(int i = 0; i < seller2.size(); i++){
		cout << seller2.at(i) << ", ";
	}
	cout << "\n";

	for(int i = 0; i < seller3.size(); i++){
		cout << seller3.at(i) << ", ";
	}
	cout << "\n";*/

	//printf("Time taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
	return 0;
}