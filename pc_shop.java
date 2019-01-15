import java.sql.*;
import java.util.*;
import java.util.logging.*;

// java -cp postgresql-9.4-1201.jdbc4.jar:. DBtest

public class pc_shop {
	public static boolean validInput = true;
	public static Scanner input = new Scanner(System.in);
	static String menu = 
			"+------------------------------+\n"+
			"|    Welcome to the pc shack   |\n"+
			"+------------------------------+\n"+
			"Select an option: \n" +
	        "  [1] - List all components and their current stock \n" +
	        "  [2] - List all somputer systems and their current stock\n" +
	        "  [3] - Price list of all inventory  \n" +
	        "  [4] - Stock manager \n" +
	        "  [5] - Buy  \n" +
	        "  [6] - Show menu \n" +
	        "  [7] - Exit";
	
	public static void main(String[] args) {
		
		// DISPLAY
		  while (true)
		    display();
		  
	}
	/*
	 	String url = "jdbc:postgresql://localhost:5432/project";
		String user = "postgres";
		String password = "a14r23";
	 * */
	
	public static void display() {
		String url = "jdbc:postgresql://localhost:5432/project";
		String user = "postgres";
		String password = "a14r23";
		Connection con = null;		
		
		//CONNECTING
		try {
			con = DriverManager.getConnection(url, user, password);

		} catch (SQLException ex) {
		        Logger lgr = Logger.getLogger(pc_shop.class.getName());
				lgr.log(Level.WARNING, ex.getMessage(), ex);

		}
		if(validInput == true){
	    System.out.println(menu);
	    validInput = false;
		}
	    try {
		    int selection = input.nextInt();
		    input.nextLine();
			     
			    switch (selection) {
			    case 1:
					list_component_current_stock(con);
			      break;
			    case 2:
			    	list_computer_system(con);
			      break;
			    case 3:
			    	price_4_all(con);
			      break; 
			    case 4:
			    	restocking(con);
			      break;
			    case 5:
				    buy(con);
			    	break;
			    case 6:
				    System.out.println(menu);
			    	break;
			    case 7:
			    	System.out.println("Exiting, goodbye!");
				    System.exit(1);
				    break;
			    default:
			      System.out.println("Invalid number");
			      break;
			    }
		    } catch(Exception e) {
	            System.out.println("Please enter valid integer input");
	            input.nextLine();
		    }
		  } // end of display
		 
	
	public static void list_component_current_stock(Connection con){
		//RUN QUERY
		try {
				Statement st = con.createStatement();
		        String query = "SELECT * FROM stock_view";
		        ResultSet rs = st.executeQuery(query);
		        System.out.println("+-----------------------------------------+------------+---------------+");
		        System.out.println("| Name                                    | Kind       | current stock |");
		        System.out.println("+-----------------------------------------+------------+---------------+");
		        while (rs.next()) {
		            	String name = rs.getString("name");
		            	String kind = rs.getString("kind");
		            	String current_stock = rs.getString("current_stock");
		            	System.out.printf("| %-40s| %-10s | %-13s | \n", name, kind, current_stock);
		        }
		        System.out.println("+-----------------------------------------+------------+---------------+");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	} //end of list_component_current_stock class
	
	public static void list_computer_system(Connection con){
		//RUN QUERY
		try {
				Statement st = con.createStatement();
		        String query = "SELECT * FROM computer_system_view";
		        ResultSet rs = st.executeQuery(query);
		        System.out.println("+-------------------------------------------+-----------------+---------------+");
		        System.out.println("| Name                                      | Kind            | current stock |");
		        System.out.println("+-------------------------------------------+-----------------+---------------+");
		        while (rs.next()) {
		            	String name = rs.getString("name");
		            	String kind = rs.getString("kind");
		            	String current_stock = rs.getString("current_stock");
		            	System.out.printf("| %-42s| %-10s | %-13s | \n", name, kind, current_stock);
		        }
		        System.out.println("+-------------------------------------------+-----------------+---------------+");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	} //end of list_computer_systemclass
	
	public static void price_4_all(Connection con){
		//RUN QUERY
		try {
				Statement st = con.createStatement();
		        String query = "SELECT id, name, kind, price, current_stock FROM stock_view UNION ALL SELECT cs_id, name, kind, price, current_stock FROM computer_system_view";
		        ResultSet rs = st.executeQuery(query);
		        System.out.println("+-------------------------------------------+-----------------+-------------+----------------+");
		        System.out.println("| Name                                      | Kind            | Price       | Current stock  |");
		        System.out.println("+-------------------------------------------+-----------------+-------------+----------------+");
		        while (rs.next()) {
		            	String name = rs.getString("name");
		            	String kind = rs.getString("kind");
		            	String price = rs.getString("price");
		            	String current_stock = rs.getString("current_stock");
		            	System.out.printf("| %-42s| %-15s | %10s  | %-14s | \n", name, kind, price, current_stock);
		        }
		        System.out.println("+-------------------------------------------+-----------------+-------------+----------------+");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	} //end of price_4_all class
	
	public static void restocking(Connection con){
		//RUN QUERY
		try {
				Statement st = con.createStatement();
		        String query = "SELECT  name, kind, current_stock FROM stock_view UNION all SELECT name, kind, current_stock FROM computer_system_view";
		        ResultSet rs = st.executeQuery(query);
		        System.out.println("+-------------------------------------------+-----------------+------------------+");
		        System.out.println("| Name                                      | Kind            | Needed to stock  |");
		        System.out.println("+-------------------------------------------+-----------------+------------------+");
		        while (rs.next()) {
		            	String name = rs.getString("name");
		            	String kind = rs.getString("kind");
		            	String current_stock = rs.getString("current_stock");
		            	int restockAmount = 150-Integer.parseInt(current_stock);
		            	System.out.printf("| %-42s| %-15s | %-16s | \n", name, kind, String.valueOf(restockAmount));
		        }
		        System.out.println("+-------------------------------------------+-----------------+------------------+");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	} //end of restocking class
	
	public static void buy(Connection con){
		//RUN QUERY
		try {
			Statement st = con.createStatement();
	        String query = "SELECT id, name, kind, price, current_stock FROM stock_view UNION ALL SELECT cs_id, name, kind, price, current_stock FROM computer_system_view";
	        ResultSet rs = st.executeQuery(query);
	        System.out.println("+-----+-------------------------------------------+-----------------+-------------+----------------+");
	        System.out.println("|id   | Name                                      | Kind            | Price       | Current stock  |");
	        System.out.println("+-----+-------------------------------------------+-----------------+-------------+----------------+");
	        while (rs.next()) {
	        		String id = rs.getString("id");
	            	String name = rs.getString("name");
	            	String kind = rs.getString("kind");
	            	String price = rs.getString("price");
	            	String current_stock = rs.getString("current_stock");
	            	System.out.printf("|%-4s | %-42s| %-15s | %10s  | %-14s | \n", id, name, kind, price, current_stock);
	        }
	        System.out.println("+-------------------------------------------------+-----------------+-------------+----------------+");
	} catch (SQLException e) {
		e.printStackTrace();
	}
		System.out.println(				
				"Select an option: \n" +
		        "  [1] - Buy component \n" +
		        "  [2] - Buy computer system\n" +
		        "  [3] - Exit to main menu ");
		validInput = false;
		try {
		    int pick = input.nextInt();
		    input.nextLine();
			     
			    switch (pick) {
			    
			    case 1: // buy component  
			    	System.out.println("Please enter ID of the desired component");  
			    	int cID = input.nextInt();
			    	Statement st = con.createStatement();
			    	String query_id = "SELECT price FROM component WHERE component.id = "+ cID;
			    	ResultSet rs = st.executeQuery(query_id);
			    	rs.next();			    					    	
			    	int price = rs.getInt("price");
			    	System.out.println("Enter Quantity of item in integer: ");
			
			    	int q = input.nextInt();{

			    	if (q > 1 && q < 12){
			    			double rabat = ((q-1)*0.02);
			    			double sum = (double) ((price*q)-((price*q)*rabat));
			    			Statement st2 = con.createStatement();
					        String query = "SELECT name FROM component WHERE component.id="+cID;
					        ResultSet rs2 = st2.executeQuery(query);
					        System.out.println("+-------------------------------------------+-----------------+------------------+");
					        System.out.println("| Name                                      | Quantity        | Total Price      |");
					        System.out.println("+-------------------------------------------+-----------------+------------------+");
					        rs2.next();
					        String name = rs2.getString("name");
					        String quant = Integer.toString(q);
					        String ss = Double.toString(sum);
					        System.out.printf("| %-42s| %-15s | %-16s | \n", name, quant, ss);
					        System.out.println("+-------------------------------------------+-----------------+------------------+\n");
					        System.out.println("Press 1 to buy OR\n"+
					        					"Press 2 to exit to menu");
					        try {
						        int pick1 = input.nextInt();
							    input.nextLine();
								     
								    switch (pick1) {
								    
								    case 1: // update stock  component
								    	Statement st3 = con.createStatement();
								        String stock_update = "UPDATE stock SET current_stock = current_stock -  "+ q +"  WHERE id in (SELECT id FROM component WHERE id =  "+ cID +" ) ";
								        st3.executeUpdate(stock_update);
								        System.out.println("CHING CHING, Please come again! \n" + "Get back to the menu by pressing 6");
								        
								    	break;
								    case 2:
								    	System.out.println(menu);
								    	break;
								    }
							    	} catch(Exception e) {
							            System.out.println("Please enter number input");
							            input.nextLine();
							    	}
					        
					        break;
					       
						}
			    	else if (q < 13);{
				      double rabat2 = (0.20);
				      double sum = (double) ((price*q)-((price*q)*rabat2));
				      Statement st2 = con.createStatement();
				        String query = "SELECT name FROM component WHERE component.id="+cID;
				        ResultSet rs2 = st2.executeQuery(query);
				        System.out.println("+-------------------------------------------+-----------------+------------------+");
				        System.out.println("| Name                                      | Quantity        | Total Price      |");
				        System.out.println("+-------------------------------------------+-----------------+------------------+");
				        rs2.next();
				        String name = rs2.getString("name");
				        String quant = Integer.toString(q);
				        String ss = Double.toString(sum);
				        System.out.printf("| %-42s| %-15s | %-16s | \n", name, quant, ss);
				        System.out.println("+-------------------------------------------+-----------------+------------------+");
				        System.out.println("Press 1 to buy OR\n"+
	        					"Press 2 to exit to menu");
					        try {
						        int pick1 = input.nextInt();
							    input.nextLine();
								     
								    switch (pick1) {
								    case 1:// update stock component 
								    	Statement st3 = con.createStatement();
								        String stock_update = "UPDATE stock SET current_stock = current_stock -  "+ q +"  WHERE id in (SELECT id FROM component WHERE id =  "+ cID +" ) ";
								        st3.executeUpdate(stock_update);
								        System.out.println("CHING CHING, Please come again! \n"+ "Get back to the menu by pressing 6");
								        
								    	break;
								    case 2:
								    	System.out.println(menu);
								    	break;
								    }
							    	} catch(Exception e) {
							            System.out.println("Please enter number input");
							            input.nextLine();
							    	}
								        break;
							    	} 	  			  
			    	}
			       
			      case 2: // buying computer system
			    		
			    	  System.out.println("Please enter ID of the desired Computer System");  
				    	int cID1 = input.nextInt();
				    	Statement st1 = con.createStatement();
				    	String query_id1 = "SELECT price FROM computer_system_view WHERE computer_system_view.cs_id = "+ cID1;
				    	ResultSet rs1 = st1.executeQuery(query_id1);
				    	rs1.next();			    					    	
				    	int price1 = rs1.getInt("price");
				    	System.out.println("Enter Quantity of item in integer: ");
				
				    	int q1 = input.nextInt();{

				    	if (q1 > 1 && q1 < 12){
				    			double rabat = ((q1-1)*0.02);
				    			double sum = (double) ((price1*q1)-((price1*q1)*rabat));
				    			Statement st2 = con.createStatement();
						        String query = "SELECT name FROM computer_system_view WHERE computer_system_view.cs_id ="+cID1;
						        ResultSet rs2 = st2.executeQuery(query);
						        System.out.println("+-------------------------------------------+-----------------+------------------+");
						        System.out.println("| Name                                      | Quantity        | Total Price      |");
						        System.out.println("+-------------------------------------------+-----------------+------------------+");
						        rs2.next();
						        String name = rs2.getString("name");
						        String quant = Integer.toString(q1);
						        String ss = Double.toString(sum);
						        System.out.printf("| %-42s| %-15s | %-16s | \n", name, quant, ss);
						        System.out.println("+-------------------------------------------+-----------------+------------------+\n");
						        System.out.println("Press 1 to buy OR\n"+
						        					"Press 2 to exit to menu");
						        try {
							        int pick1 = input.nextInt();
								    input.nextLine();
									     
									    switch (pick1) {
									    case 1: // updating stock
									    	Statement st3 = con.createStatement();
									        String stock_update = "UPDATE stock SET current_stock = current_stock - "+q1+" WHERE id in ((SELECT cpu FROM computer_system WHERE cs_id = "+cID1+") UNION (SELECT mainboard FROM computer_system WHERE cs_id = "+cID1+") UNION (SELECT ram FROM computer_system WHERE cs_id = "+ cID1+") UNION (SELECT cabine FROM computer_system WHERE cs_id = "+cID1+") UNION(SELECT gfx FROM computer_system WHERE cs_id = "+cID1+"));";
									        st3.executeUpdate(stock_update);
									        System.out.println("CHING CHING, Please come again! \n"+ "Get back to the menu by pressing 6");
									        
									    	break;
									    case 2:
									    	System.out.println(menu);
									    	break;
									    }
								    	} catch(Exception e) {
								            System.out.println("Please enter number input");
								            input.nextLine();
								    	}
						        
						        break;
						       
							}
				    	else if (q1 < 13);{
				    		double rabat = ((q1-1)*0.02);
			    			double sum = (double) ((price1*q1)-((price1*q1)*rabat));
			    			Statement st2 = con.createStatement();
					        String query = "SELECT name FROM computer_system_view WHERE computer_system_view.cs_id ="+cID1;
					        ResultSet rs2 = st2.executeQuery(query);
					        System.out.println("+-------------------------------------------+-----------------+------------------+");
					        System.out.println("| Name                                      | Quantity        | Total Price      |");
					        System.out.println("+-------------------------------------------+-----------------+------------------+");
					        rs2.next();
					        String name = rs2.getString("name");
					        String quant = Integer.toString(q1);
					        String ss = Double.toString(sum);
					        System.out.printf("| %-42s| %-15s | %-16s | \n", name, quant, ss);
					        System.out.println("+-------------------------------------------+-----------------+------------------+\n");
					        System.out.println("Press 1 to buy OR\n"+
					        					"Press 2 to exit to menu");
					        try {
						        int pick1 = input.nextInt();
							    input.nextLine();
								     
								    switch (pick1) {
								    case 1: // updating stock
								    	Statement st3 = con.createStatement();
								        String stock_update = "UPDATE stock SET current_stock = current_stock - "+q1+" WHERE id in ((SELECT cpu FROM computer_system WHERE cs_id = "+cID1+") UNION (SELECT mainboard FROM computer_system WHERE cs_id = "+cID1+") UNION (SELECT ram FROM computer_system WHERE cs_id = "+ cID1+") UNION (SELECT cabine FROM computer_system WHERE cs_id = "+cID1+") UNION(SELECT gfx FROM computer_system WHERE cs_id = "+cID1+"));";
								        st3.executeUpdate(stock_update);
								        System.out.println("CHING CHING, Please come again! \n"+ "Get back to the menu by pressing 6");
								        
								    	break;
								    case 2:
								    	System.out.println(menu);
								    	break;
								    }
							    	} catch(Exception e) {
							            System.out.println("Please enter number input");
							            input.nextLine();
							    	}
					        
					        break;
								    	} 	  			  
				    	}
				       
			      case 3:
			    	System.out.println(menu);;
				    break;
			    default:
			      System.out.println("WRONG number");
			      break;
			    }
		    } catch(Exception e) {
	            System.out.println("Please enter number input");
	            input.nextLine();
		    }
	} //end of buy class

	
	}// end of pc_shop class