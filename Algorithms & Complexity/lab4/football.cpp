//C++ Implementation of Kosaraju's algorithm to print all SCCs 
//source: https://www.geeksforgeeks.org/strongly-connected-components/

#include <iostream> 
#include <list> 
#include <stack> 
#include <stdio.h>
#include <fstream>  

using namespace std; 

int result = 0;

class Graph { 
	int V;
	list<int> *adj;
	void fillOrder(int v, bool visited[], stack<int> &Stack); 
	void DFSUtil(int v, bool visited[]); 
public: 
	Graph(int V); 
	void addEdge(int v, int w);  
	void findSCCs(); 
	Graph getTranspose(); 
}; 

Graph::Graph(int V){ 
	this->V = V; 
	adj = new list<int>[V]; 
}  
void Graph::DFSUtil(int v, bool visited[]){  
	visited[v] = true; 
	result++;
	list<int>::iterator i; 
	for (i = adj[v].begin(); i != adj[v].end(); ++i) 
		if (!visited[*i]) 
			DFSUtil(*i, visited); 
} 

Graph Graph::getTranspose(){ 
	Graph g(V); 
	for (int v = 0; v < V; v++){  
		list<int>::iterator i; 
		for(i = adj[v].begin(); i != adj[v].end(); ++i){ 
			g.adj[*i].push_back(v); 
		} 
	} 
	return g; 
} 

void Graph::addEdge(int v, int w){ 
	adj[v].push_back(w); 
} 

void Graph::fillOrder(int v, bool visited[], stack<int> &Stack){  
	visited[v] = true; 
	list<int>::iterator i; 
	for(i = adj[v].begin(); i != adj[v].end(); ++i) 
		if(!visited[*i]) 
			fillOrder(*i, visited, Stack); 
	Stack.push(v); 
} 

void Graph::findSCCs() { 
	stack<int> Stack; 
	bool *visited = new bool[V]; 
	for(int i = 0; i < V; i++) 
		visited[i] = false; 
	for(int i = 0; i < V; i++) 
		if(visited[i] == false) 
			fillOrder(i, visited, Stack);
	Graph gr = getTranspose(); 
	for(int i = 0; i < V; i++) 
		visited[i] = false; 
	while (Stack.empty() == false) { 
		int v = Stack.top(); 
		Stack.pop(); 
		if (visited[v] == false) { 
			result = 0;
			gr.DFSUtil(v, visited); 
		} 
	} 
} 

int main(int argc, char **argv) { 

	//to read from file
	//ifstream infile;
	//infile.open(argv[1]);
	//clock_t tStart = clock();

	int N,k;
	long long int M;
	
	cin >> N;
	//infile >> N;
	
	Graph g(N);

	for (int i = 0; i < N; i++){
		cin >> M; 
		//infile >> M;
		
		for (long long int j = 0; j < M; j++){
			cin >> k;
			//infile >> k;
			g.addEdge(i, k-1);
		}
	}

	g.findSCCs(); 

	cout << result << "\n";
	//printf("\nTime taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);

	return 0; 
} 