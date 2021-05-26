import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;

class Astar {
	
	static void tracePath(Coordinates coords, ArrayList<Coordinates> path,HashMap<Coordinates,Node> map,Coordinates start,PrintWriter writer) {
		path.add(coords);
		if(coords.equals(start)) {
			writer.print("New Path\n\n");
			Main.printList(path,writer);
			writer.print("\n\n");
			
		}
		else {
			for (int i=0;i<map.get(coords).fathers.size();i++) {
				tracePath(map.get(coords).fathers.get(i),path,map,start,writer);
				path.remove(path.size()-1);
				
				
			}
		}
	}
	
	static Double aFunc (HashMap<Coordinates,Node> map,Coordinates start, Coordinates end, PrintWriter writer) {
	
		ArrayList<Coordinates> openList = new ArrayList<Coordinates>();
		HashSet<Coordinates> closedList = new HashSet<Coordinates>();
		openList.add(start);
		
		Coordinates successorQ = null;
		Double cost = 0.0;
		Boolean flag_while = false;
		ArrayList<Coordinates> fathersSuccessor = new ArrayList<Coordinates>();
		
		while(!openList.isEmpty() && flag_while == false) {		//check open list
			
			Collections.sort(openList);		//incrementing sorting CHECK
			Coordinates q = openList.get(0);
			
			if(q.equals(end)) {	//if goal
				flag_while=true;
				break;
			}
			else {
				ArrayList<Coordinates> neighborsQ = map.get(q).getNeighbors();
				for(int i = 0 ; i<neighborsQ.size(); i++) {
					successorQ = neighborsQ.get(i);			//we get the neighbor
					fathersSuccessor = map.get(successorQ).fathers;
		
					if(closedList.contains(successorQ)) {	//hashSet
						;	//skip this successor
					}
					else if(openList.contains(successorQ)) {	//in the openList
						
						Double G = q.getG() + Havershine.heuristic(Double.parseDouble(q.x),Double.parseDouble(successorQ.x),Double.parseDouble(q.y),Double.parseDouble(successorQ.y));
						Integer index = openList.indexOf(successorQ);	// get the index of the successor
						Double GInOpenList = openList.get(index).getG();
						
						if (Math.abs(G-GInOpenList)<=0.001) {		//ipothetoume oti G se openList == G se map
							map.get(successorQ).fathers.add(q);	//add father
						}
						else if (G<GInOpenList) {
							map.get(successorQ).fathers.clear(); //clear fathers
							map.get(successorQ).fathers.add(q); //add q in fathers
							openList.get(index).g = G; //replace G in openList
							successorQ.g = G;	//replace G in map
							openList.get(index).f = G+openList.get(index).h;
							successorQ.f = openList.get(index).f;
						}
					}
					else { //fathers and f,g,h
						Double G = q.getG() + Havershine.heuristic(Double.parseDouble(q.x),Double.parseDouble(successorQ.x),Double.parseDouble(q.y),Double.parseDouble(successorQ.y));
						successorQ.g = G;
						Double H = Havershine.heuristic(Double.parseDouble(end.x),Double.parseDouble(successorQ.x),Double.parseDouble(end.y),Double.parseDouble(successorQ.y));
						successorQ.h = H;
						successorQ.f = G + H;
						fathersSuccessor.add(q);
						openList.add(successorQ);
					}
				} //end of for
			}
			
			closedList.add(q);
			openList.remove(q);
		}// end of while
		
		/*Double cost = successorQ.getF();
		ArrayList <Coordinates> path = new ArrayList<Coordinates>();
		tracePath(successorQ,path, map, start);*/
		if (flag_while == true) {	//if a path to the goal was found*/
			cost = successorQ.getF(); 
			ArrayList <Coordinates> path = new ArrayList<Coordinates>();
			tracePath(successorQ,path, map, start,writer);
		}
		else {
			System.out.println("Path to goal not found!Astar failed!\n");
		}
		
		return cost;

	} // end of static 
} // end of class

	
	




















