#include <iostream>
#include <time.h>
#include <fstream>  
#include <limits.h>
#include <vector>
#include <set>
#include <queue>

using namespace std; 

struct Node {
	int dest;
	int weight;
};

struct NodeHeap {
	int src;
	int dist = INT_MAX;
};

// implementation for min heap
struct CompareDist {
    bool operator()(NodeHeap const& a, NodeHeap const& b){
        return a.dist > b.dist;
    }
};

void create_edge(vector<Node> adj[], int a, int b, int c){
	
	Node tmp;
	tmp.weight = c;
	tmp.dest = b;
	adj[a].push_back(tmp);

	tmp.dest = a;
	adj[b].push_back(tmp);
}

//returns MST as parents' array
void prim(int s, vector<Node> adj[], int N, int M, vector<int> &parents, vector<int> &distances){

	//create min heap for distances for each vertex to connect to MST
	priority_queue <NodeHeap,vector<NodeHeap>,CompareDist> minHeap;
	
	//initializations
	for(int i = 0; i < N; i++){
		NodeHeap tmp;
		tmp.src = i;
		if(i == s)
			tmp.dist = 0;
		else
			tmp.dist = INT_MAX;
		distances.push_back(tmp.dist);
		minHeap.push(tmp);
	}

	//parent of s is s
	for(int i = 0; i < N; i++)
		parents.push_back(-1);
	parents.at(s) = s;

	//nodes that need to be visited
	set<int> missing;
	for(int i = 0; i < N; i++)
		missing.insert(i);

	while(!missing.empty()){

		//add the one with smaller distance in the tree
		NodeHeap tmp = minHeap.top();
		minHeap.pop();
		int u = tmp.src;
		int dist = tmp.dist;

		//remove element if it had to be visited + visit its children
		if(missing.find(u) != missing.end()){	
			missing.erase(u);
			
			for(Node n : adj[u]){
				int v = n.dest;
				int w = n.weight;
				if(missing.find(v) != missing.end() && distances.at(v) > w){
					distances.at(v) = w;
					tmp.src = v;
					tmp.dist = w;
					minHeap.push(tmp);
					parents.at(v) = u;
				}
			}
		}
	}
}


int dfs(int pos, vector<int> &nodeDesc, vector<Node> adj[], int N, vector<pair<int,int>> &times) {
	
	//cout << "DFS for node: " << pos << "\n";
	vector<Node> children = adj[pos];
	
	if (children.empty()) {
		return 1;
	}
	
	for (Node n : children) {
		if(n.dest != pos){
			nodeDesc.at(pos) += dfs(n.dest, nodeDesc, adj, N, times);
			int nDesc = nodeDesc.at(n.dest);
			pair<int,int> tmp = make_pair(n.weight, (nDesc+1)*(N-nDesc-1));
			times.push_back(tmp);
		}

	}
	//cout << "DFS for node: " << pos << ", descendants: " << nodeDesc.at(pos) + 1 <<"\n";
	return nodeDesc.at(pos) + 1;
}

void decToBinary(int n, int N, vector<int> &positions, int plus){ 
	int i = 0;
	while (n > 0){ 
		if (n % 2)
			positions.push_back(i+plus);
		n = n / 2;
		i++;
	}
} 

int main (int argc, char **argv) {

	//to read from file
	ifstream infile;
	infile.open(argv[1]);
	//clock_t tStart = clock();

	//read input 
	int N, M;
	//scanf("%d", &N);
	//scanf("%d", &M);
	infile >> N >> M;

	//create graph as adjacency list
	//nodes are labeled from 1 to N in input
	vector<Node> adj[N];
	int a,b,c;
	for(int i = 0; i < M; i++){
		//scanf("%d", &a);
		//scanf("%d", &b);
		//scanf("%d", &c);
		infile >> a >> b >> c;
		create_edge(adj, a-1, b-1, c);
	}

	//since weights are unique + no power of 2 can be written as sum of unique smaller powers of 2, MST == tree of all shortest paths
	vector<int> parents;
	vector<int> distances;
	prim(0, adj, N, M, parents, distances);
	
	/*cout << "Printing parents MST\n";
	for(int i = 0; i < parents.size(); i++)
		cout << parents.at(i) << ", ";*/

	/*cout << "\nPrinting distances MST\n";
	for(int i = 0; i < distances.size(); i++)
		cout << distances.at(i) << ", ";*/

	//convert MST to adj list
	vector<Node> MST[N];
	for(int i = 0; i < N; i++){
		int p = parents[i];
		Node tmp;
		tmp.dest = i;
		tmp.weight = distances.at(i);
		MST[p].push_back(tmp);
	}

	/*cout << "\nPrinting MST\n";
	for(int i = 0; i < N; i++){
		for(int j = 0; j < MST[i].size(); j++){
			Node n = MST[i].at(j);
			cout << i << " - " << n.dest << " with edge: " << n.weight << "\n";
		}
	}*/

	//find number of descendants per node
	vector<int> nodeDesc;
	for(int i = 0; i < N; i++)
		nodeDesc.push_back(0);

	vector<pair<int,int>> times;
	nodeDesc.at(0) = dfs(0, nodeDesc, MST, N, times);

	//calculate result in binary form
	int *sum;
	sum = new int[32*M];
	for(int i = 0; i < 32*M; i++)
		sum[i] = 0;
	
	int i, max = 0;
	vector<int> positions;
	for(auto x: times){
		decToBinary(x.second, N, positions, x.first);
		for(auto y: positions){ 
			i = y;
			if (sum[y]){
				while (sum[i]){
					sum[i] = 0;
					i++;
				}
				sum[i] = 1;
			}
			else 
				sum[y] = 1;
		}
		if(i > max) 
			max = i;
		positions.clear();
	}

	//print result
	for (int j = max; j >= 0 ; j--)
		cout << sum[j];
	cout << "\n";

    //printf("\nTime taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    return 0;
}