import java.util.HashMap;
import java.util.Map;

 class FindGoal {

	public static Coordinates findGoal(HashMap<Coordinates, Node> map, String clientX, String clientY) {
		Coordinates goal = new Coordinates (null,null);
				// turn string into doubles:
				Double client_X = Double.parseDouble(clientX);// turn string into double
				Double client_Y = Double.parseDouble(clientY);
				//initialize variables min, targetX,targetY:
				Double min = 100000.0;
				Double targetX= 0.0;
	     	    Double targetY =0.0;
				for(Map.Entry<Coordinates, Node> entry : map.entrySet()) {//check all map coordinates and find the closest one to client
	        	    Coordinates key = entry.getKey();
	        	 
	        	    String x = key.getx();
	        	    String  y = key.gety();
	        	    Double nodeX = Double.parseDouble(x);
	        	    Double nodeY = Double.parseDouble(y);
	        	    Double distance= Havershine.heuristic(client_X,nodeX,client_Y,nodeY);
	        	   
	        	    if (distance < min) {
	        	    	min = distance;
	        	    	targetX = nodeX;
	        	    	targetY = nodeY;
	        	    } 
	        	 }
				  //System.out.println(min);
				  //System.out.println( "target x is "+ targetX + "target y is "+ targetY);
				  String tX = String.valueOf(targetX);//turn it back into string
				  String tY = String.valueOf(targetY);//turn it back into string
				   goal = new Coordinates(tX,tY); // create new target object 
				 
			//}
			/*catch (FileNotFoundException e) {
				e.printStackTrace();		
		
	} */
		return goal;
	}
}
