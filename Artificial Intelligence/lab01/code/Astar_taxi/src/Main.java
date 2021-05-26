import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Scanner;

class Coordinates implements Comparable<Coordinates>{
	String x,y;
	Double f=0.0;
	Double g=0.0;
	Double h=0.0;
	
	Double getF(){
		return f;
	}
	Double getG(){
		return g;
	}
	Double getH(){
		return g;
	}
	Coordinates(String x,String y){
		this.x=x;
		this.y=y;
	}
	String getx() {
		return x; 
	}
	String gety() {
		return y; 
	}
	public int compareTo(Coordinates user) {
		  return Double.compare(f, user.f);
		}
	
	public boolean equals(Object data) {
		if(data == this) return true;
		if (!(data instanceof Coordinates)) return false;
		Coordinates coordinates = (Coordinates) data;
		return coordinates.x.equals(x) && coordinates.y.equals(y);
	}
	
	public int hashCode() {	//equal objects need to have the same HashCode, but different might also have the same
		return Objects.hash(x,y);
	}
}

class Node  {
	ArrayList <Coordinates> neighbors = new ArrayList<Coordinates>();	//creates an empty list with an initial capacity sufficient to hold 10 elements
	ArrayList <Coordinates> fathers = new ArrayList<Coordinates>();
	
	ArrayList<Coordinates> getNeighbors(){
		return neighbors;
	}
	ArrayList<Coordinates> getFathers(){
		return fathers;
	}
	
}

public class Main {
	
	public static void printList(ArrayList <Coordinates> list, PrintWriter writer) {		//printing a list of elements of type Coordinates
	
		if(list.isEmpty()) 
			writer.print("List is empty");
		else {	
				for(int i=0; i<list.size(); i++) {
	        	    Coordinates point = list.get(i);
	        	    String x = point.getx();
	        	    String y = point.gety();
					//Double f = point.getF();
	        	    writer.print(x + "," + y+",0\n");
	        	}
			
		}
		
	}
	
	/*public static void print(HashMap<Coordinates, Node> map){ 		//used to print the map
		if (map.isEmpty())
            System.out.println("Map is empty"); 
        else {
        	for(Map.Entry<Coordinates, Node> entry : map.entrySet()) {
        	    Coordinates key = entry.getKey();
        	    String x = key.getx();
        	    String y = key.gety();
        	    Node value = entry.getValue();
        	    System.out.print("key = " + x + "," + y   + "  neighbors = {" );
        	    printList(value.getNeighbors());
        	    System.out.println("}" );
        	}
        }
    }*/
	
	public static void main(String[] args){

		HashMap<Coordinates, Node> map = new HashMap<Coordinates, Node>();		//the map			
		String x,y,id;
		Coordinates data,last_checked_data;										//the coordinates of the last point that was checked
		String last_checked_addr=null; 											//the address of the last point that was checked
		Node values;
		
		try {
			
			FileReader file = new FileReader("nodes.csv");
			Scanner inputStream = new Scanner(file);
			inputStream.useDelimiter("(\\p{javaWhitespace}|\\,)+");

			if(inputStream.hasNextLine()) {			//if it is not an empty file
				inputStream.nextLine();				//line of the labels X,Y,id,name (show to the 2nd line of the file)
			
				x = inputStream.next();
				y = inputStream.next(); 			
				id = inputStream.next();	
				data = new Coordinates(x,y);
				values = new Node();
				
				map.put(data, values);
				
				last_checked_addr = id;				//the address of the previously checked element
				last_checked_data = data;			//the key of the previously checked element
				
				if(inputStream.hasNextLine()) inputStream.nextLine();
				
				while(inputStream.hasNextLine()) {
					
					x = inputStream.next();			//we keep only the fields we need, not the address one
					y = inputStream.next(); 
					data = new Coordinates(x,y);
					id = inputStream.next();	
					
					if (!map.containsKey(data)){ 	//if this point is not in the graph
						 
						values = new Node();								//initialize an empty list for the new point in the graph
						
						if(id.equals(last_checked_addr)){					//the last checked point is in the same address as this one
							 
							values.neighbors.add(last_checked_data);		//vale thn akmitou proigoumenoy
							 
							Node prev_data = map.get(last_checked_data);	//pare to value tou proigoymenoy
							prev_data.neighbors.add(data);					//add sto value tou proigoumenou ta nea data
							map.put(last_checked_data,prev_data);			//vale stis akmes tou proigoumenoyshmeioy ayti pou eimaste twra
						 
						}
						 
						map.put(data,values);		//adding the new point, the cross-roads are not added in the map
				    }	
					else {							//if the point is in the graph, it is a cross-road
						
						if(id.equals(last_checked_addr)){					//if in the same address as previously checked
							
							Node old_values = map.get(data);
							old_values.neighbors.add(last_checked_data);	//find its values and add the previously checked point 
							map.put(data, old_values);
							
							Node prev_values = map.get(last_checked_data);
							prev_values.neighbors.add(data);
							map.put(last_checked_data,prev_values);
						}
					}
					
					last_checked_addr = id;		//the address of the previously checked element
					last_checked_data = data;	//the key of the previously checked element
					
					if(inputStream.hasNextLine()) inputStream.nextLine();
				}
			}
				inputStream.close();
				//print(map);
				//System.out.println(map.size());		//number of map's nodes
		}
		catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		
		// find closest node for client-target point
		Coordinates goal = null;
		try{
			FileReader file = new FileReader("ourclient.csv");// open the client file
			Scanner inputStream = new Scanner(file);
			inputStream.useDelimiter("(\\p{javaWhitespace}|\\,)+");
			inputStream.nextLine();				//line of the labels X,Y (show to the 2nd line of the file)
			String clientX = inputStream.next();//read x 
			String clientY = inputStream.next(); //read y
			goal = FindGoal.findGoal(map,clientX,clientY);
			inputStream.close();
		}
		catch (FileNotFoundException e) {
			e.printStackTrace();		
		} 
		
		// find closest node for each starting taxi point
		ArrayList <Coordinates> taxis_start = new ArrayList <Coordinates>(); 
		try{
			FileReader file = new FileReader("ourtaxis.csv");// open the client file
			Scanner inputStream = new Scanner(file);
			inputStream.useDelimiter("(\\p{javaWhitespace}|\\,)+");
			inputStream.nextLine();				//line of the labels X,Y (show to the 2nd line of the file)
			
			while(inputStream.hasNextLine()) {
				
				String taxiX = inputStream.next();//read x 
				String taxiY = inputStream.next(); //read y
				if(inputStream.hasNextLine())	inputStream.nextLine();
				Coordinates start = FindGoal.findGoal(map,taxiX,taxiY);
				//System.out.println("Taxi with coordinates: (" + taxiX + "," + taxiY + "), corresponded to: (" + start.getx() + "," + start.gety() + ")\n");
				taxis_start.add(start);
			}
			inputStream.close();
		}
		catch (FileNotFoundException e) {
			e.printStackTrace();		
		} 
		PrintWriter writer;
		try {				
			writer = new PrintWriter("output.txt", "UTF-8");
			for(int i=0; i<taxis_start.size(); i++) {	//run Astar for each taxi
				writer.print(i + " repetion.The cost of taxi with coordinates in the graph = (" + taxis_start.get(i).x + "," + taxis_start.get(i).y + ") has cost : " 
				+ Astar.aFunc(map,taxis_start.get(i),goal,writer) + "\n\n" );
				for(Map.Entry<Coordinates, Node> entry : map.entrySet()) {
	        	    Coordinates key = entry.getKey();
	        	    key.g=0.0;
	        	    key.h=0.0;
	        	    key.f=0.0;
	        	    Node value = entry.getValue();
	        	    value.fathers.clear();
	        	}
			
				
			}writer.close();
		}catch (FileNotFoundException | UnsupportedEncodingException e) {
			e.printStackTrace();
		}

	}
}

