#include <iostream>  
#include <time.h>  
#include <fstream>    
#include <limits.h>  
#include <vector>  
#include <set>  
#include <queue>  
  
using namespace std;   
  
int main (int argc, char **argv) {  
  
    //to read from file  
    ifstream infile; 
    infile.open(argv[1]); 
    //clock_t tStart = clock();  
  
    //read input   
    int N, Q;  
    //scanf("%d", &N);  
    //scanf("%d", &Q);  
    infile >> N >> Q;  
  
    // allowed distances  
    vector<int> dists;  
    for(int i = 0; i < N; i++){  
        int tmp;   
        //scanf("%d", &tmp);
        infile >> tmp;   
        dists.push_back(tmp);  
    }  
  
    // queries  
    int min_query = INT_MAX;  
    int max_query = INT_MIN;  
      
    vector<int> queries;  
    for(int i = 0; i < Q; i++){  
        int tmp;  
        infile >> tmp;  
        //scanf("%d", &tmp);  
        queries.push_back(tmp);  
        if(tmp > max_query)  
            max_query = tmp;  
        if(tmp < min_query)  
            min_query = tmp;          
    }  

    cout << "N: " << N << "\n";
    cout << "min_query: " << min_query << "\n";
    cout << "max_query: " << max_query << "\n";

    int dp[1000][10001];
    
    //int dp[N + 1][max_query + 1];  

    /*
      
    for(int i = 0; i <= N; i++){  
        for(j = 0; j <= max_query; j++)  
            dp[i][j] = 0;  
  
    } 

    /*
  
    for(long int i = 0; i <= N; i++)  
        dp[i][0] = 1;  
  
    for(long int i = 1; i <= N; i++){  
        long int cur = dists.at(i-1);  
        for(long int j = 1; j <= max_query; j++){   
            if (j - cur < 0)  
                dp[i][j] = dp[i-1][j];  
            else if (dp[i-1][j] + dp[i][j-cur] > 0)  
                dp[i][j] = 1;  
            else   
                dp[i][j] = 0;  
        }  
    }  
  
    for(long int i = 0; i < Q; i++){  
        long int cur = queries.at(i);          
        long int val = dp[N][cur];  
        if(val == 0)  
            printf("NO\n");  
        else  
            printf("YES\n");      
  
    }  */
  
    //printf("\nTime taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);  
    return 0;  
}  