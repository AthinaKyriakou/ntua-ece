#include <iostream>  
#include <time.h> 
#include <vector>
#include <algorithm>    
#include <fstream>
#include <limits.h>    
#include <queue>
  
using namespace std;   

// implementation for the 25% of the test cases where there is only one path s --> t

struct node {
  int to_node;
  int weight;
};

typedef pair<int, int> iPair;

int main(int argc, char **argv) {

	// read input

	// to read from file  
    ifstream infile; 
    infile.open(argv[1]);

    int N, M, s, t, B;  
    scanf("%d", &N);  
    scanf("%d", &M);
    scanf("%d", &s);  
    scanf("%d", &t); 
    scanf("%d", &B);  
    //infile >> N >> M >> s >> t >> B; 
    s--;
    t--;

	// create graph in adj list from input 
	// input in the form (ui, vi, li), nodes given start from 1
	vector<node> graph[N];
	for(int i = 0; i < M; i++){
		int u, v, l;
		node tmp;

		scanf("%d", &u);  
		scanf("%d", &v);
		scanf("%d", &l);

		//infile >> u >> v >> l;
		u--;
		v--; 
		tmp.to_node = v;
		tmp.weight = l;
		graph[u].push_back(tmp);

	}

	// dijkstra from s to find the single path to t
	// a dijkstra variant could be used to solve the general case
	// use of priority queue with the path cost per node
	
	priority_queue< iPair, vector <iPair> , greater<iPair> > pq;
	int dijkstra_cost[N];
	int parents[N];
	int weights[N];

	for(int i = 0; i < N; i++){
		dijkstra_cost[i] = INT_MAX;
		parents[i] = -1;
		weights[i] = -1;
	} 
	
	dijkstra_cost[s] = 0;
	pq.push(make_pair(0, s));

	while(!pq.empty()) {
		
		int u = pq.top().second;
		pq.pop();
		vector<node> adj_list = graph[u];

		for(int i = 0; i < adj_list.size(); i++){
			node tmp = adj_list.at(i);
			int v = tmp.to_node;
			int l = tmp.weight;

			if(dijkstra_cost[v] > dijkstra_cost[u] + l){
				dijkstra_cost[v] = dijkstra_cost[u] + l;
				parents[v] = u;
				weights[v] = l;
				pq.push(make_pair(dijkstra_cost[v], v));
			}
		}
	}


	// find the edges in the s-t path
	int path_length = dijkstra_cost[t];
	vector<int> distances;

	int cur = t;
	while(cur != s){
		int p = parents[cur];
		distances.push_back(weights[cur]);
		cur = p;
	}

	// start removing the heaviest edges
	sort(distances.begin(), distances.end());
	int edges_to_remove = 0;

	// printing check
	/*cout << "Distances: ";
	for(int i = 0; i < distances.size(); i++){
		cout << distances.at(i) << " ";
	}
	cout << "\n";*/

	while(path_length > B && path_length > -1){
		path_length -= distances.back();
		distances.pop_back();
		edges_to_remove++;
	}

	printf("%d\n", edges_to_remove); 
	return 0;
}