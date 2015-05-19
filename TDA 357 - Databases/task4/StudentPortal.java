import java.sql.*; // JDBC stuff.
import java.io.*;  // Reading user input.

public class StudentPortal
{
	/* This is the driving engine of the program. It parses the
	 * command-line arguments and calls the appropriate methods in
	 * the other classes.
	 *
	 * You should edit this file in two ways:
	 * 	1) 	Insert your database username and password (no @medic1!)
	 *		in the proper places.
	 *	2)	Implement the three functions getInformation, registerStudent
	 *		and unregisterStudent.
	 */
	public static void main(String[] args)
	{
		if (args.length == 1) {
			try {
				DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
				String url = "jdbc:oracle:thin:@db.student.chalmers.se:1521/kingu.ita.chalmers.se";
				String userName = "htda357_091"; // Your username goes here!
				String password = "htda357_091"; // Your password goes here!
				Connection conn = DriverManager.getConnection(url,userName,password);

				String student = args[0]; // This is the identifier for the student.
				BufferedReader input = new BufferedReader(new InputStreamReader(System.in));
				System.out.println("Welcome!");
				while(true) {
					System.out.println("Please choose a mode of operation:");
					System.out.print("? > ");
					String mode = input.readLine();
					if ((new String("information")).startsWith(mode.toLowerCase())) {
						/* Information mode */
						getInformation(conn, student);
					} else if ((new String("register")).startsWith(mode.toLowerCase())) {
						/* Register student mode */
						System.out.print("Register for what course? > ");
						String course = input.readLine();
						registerStudent(conn, student, course);
					} else if ((new String("unregister")).startsWith(mode.toLowerCase())) {
						/* Unregister student mode */
						System.out.print("Unregister from what course? > ");
						String course = input.readLine();
						unregisterStudent(conn, student, course);
					} else if ((new String("quit")).startsWith(mode.toLowerCase())) {
						System.out.println("Goodbye!");
						break;
					} else {
						System.out.println("Unknown argument, please choose either " +
									 "information, register, unregister or quit!");
						continue;
					}
				}
				conn.close();
			} catch (SQLException e) {
				System.err.println(e);
				System.exit(2);
			} catch (IOException e) {
				System.err.println(e);
				System.exit(2);
			}
		} else {
			System.err.println("Wrong number of arguments");
			System.exit(3);
		}
	}

	static void getInformation(Connection conn, String student)
	{
		String studentInfoQuery = "SELECT name, programname, branchname FROM StudentsFollowing WHERE id='"+student+ "'";
		String readCoursesQuery = "SELECT course, coursename, grade, credits FROM FinishedCourses WHERE student='"+student+"'";
		String registeredCoursesQuery = "SELECT course, coursename, credits, status, queuepos FROM RegisteredCoursesRelation WHERE student='"+student+"'";
		String graduationQuery =  "SELECT seminarcredits, mathcredits, researchcredits, numcredits, graduated FROM PathToGraduation WHERE id='"+student+"'";
		String[][] sIResultArray;
		String[][] rCResultArray;
		String[][] regCResultArray;
		String[][] gradResultArray;
		try {
			Statement myStatement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
			
			int rowSize = 0;
			ResultSet rslt = myStatement.executeQuery(studentInfoQuery);
			sIResultArray = resultToArray(rslt);
			rslt = myStatement.executeQuery(readCoursesQuery);
			rCResultArray = resultToArray(rslt);
			rslt = myStatement.executeQuery(registeredCoursesQuery);
			regCResultArray = resultToArray(rslt);
			rslt = myStatement.executeQuery(graduationQuery);
			gradResultArray = resultToArray(rslt);
			myStatement.close();
			System.out.println("Information for student '"+student+"'");
			System.out.println("--------------------------------------------------");
			System.out.println("Name: "+ sIResultArray[0][0]);
			System.out.println("Program: "+ sIResultArray[0][1]);
			System.out.println("Branch: "+ sIResultArray[0][2]);
			System.out.println();
			System.out.println("Read courses (name (code), credits: grade):");
			System.out.println("--------------------------------------------------");
			if (rCResultArray != null) {
				for (String[] course : rCResultArray) {
					System.out.println("  "+course[1]+" ("+course[0]+"), "+course[3]+": "+course[2]);
				}
			}
			System.out.println();
			System.out.println("Registered courses (name (code), credits: status):");
			System.out.println("--------------------------------------------------");
			if (regCResultArray != null) {
			for (String[] course : regCResultArray) {
					String outstring = "  "+course[1]+" ("+course[0]+"), "+course[2]+": "+course[3] + (course[3].trim().equals("waiting") ? " as nr "+ course[4] : "" );
					System.out.println(outstring);
				}
			}
			System.out.println();
			System.out.println("Seminar credits taken: "+gradResultArray[0][0]);
			System.out.println("Math credits taken: "+gradResultArray[0][1]);
			System.out.println("Research credits taken: "+gradResultArray[0][2]);						
			System.out.println("total credits taken: "+gradResultArray[0][3]);
			System.out.println("graduated "+(Integer.parseInt(gradResultArray[0][4]) == 1 ? "yes" : "no" ));

		} catch (SQLException e) {
			System.err.println("sql exception in getInfo()");
			System.err.println(e);
			e.printStackTrace();
			System.exit(2);
		}

	}

	static void registerStudent(Connection conn, String student, String course)
	{
		String checkReg = "SELECT status,coursename,queuepos FROM RegisteredCoursesRelation where student='"+student+"' AND course='"+course+"'";
		String[][] queryArr;
		try {
			Statement readStatement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
			PreparedStatement writeStatement = conn.prepareStatement("INSERT INTO Registrations (course,student) VALUES (?,?)");
			ResultSet rs = readStatement.executeQuery(checkReg);
			queryArr = resultToArray(rs);

			if (queryArr != null) {
					System.out.println("An Error Occured: You had previously been registered for "+course+" "+queryArr[0][1]+"!");
			} else {
				writeStatement.setString(1,course);
				writeStatement.setString(2,student);
				writeStatement.execute();
				int rowsAffected = writeStatement.getUpdateCount();
				writeStatement.close();

				rs = readStatement.executeQuery(checkReg);
				queryArr = resultToArray(rs);
				if (rowsAffected > 0 && queryArr[0][0].trim().equals("registered")) {
					System.out.println("You have successfully registered for "+course+" "+queryArr[0][1]+"!");
				} else if (rowsAffected > 0 && queryArr[0][0].trim().equals("waiting")) {
					System.out.println("Course "+course+" "+queryArr[0][1]+" is full. You have been placed on the waiting list in position "+queryArr[0][2]);
				} else {
					System.out.println("Course registration failed! Do you meet all the prerequisites?/Have you taken this course before?");
				}


			}
			readStatement.close();

		} catch (SQLException e) {
			if (e.getErrorCode() == 20001) {
				System.out.println("Prerequisites not met!");
			} else if (e.getErrorCode() == 20000) {
				System.out.println("You are already registered for this course!");
			} else if (e.getErrorCode() == 20002) {
				System.out.println("You have already passed this course!");
			} else if (e.getErrorCode() == 20003) {
				System.out.println("You are already waiting!");
			} else {
				System.err.println("unhandled sql exception in register");
				System.err.println(e);
				e.printStackTrace();
				System.exit(2);
			} 		
		}
		
	}

	static void unregisterStudent(Connection conn, String student, String course)
	{
		PreparedStatement writeStatement;
		try {
			writeStatement = conn.prepareStatement("DELETE FROM Registrations WHERE student='"+student+"' AND course='"+course+"'");
			writeStatement.execute();
			int rowsAffected = writeStatement.getUpdateCount();
			if (rowsAffected > 0) {
				System.out.println("You have been unregistered from "+course+".");
			} else {
				System.out.println("You are not registered for "+course+".");
			}

			writeStatement.close();
		} catch (SQLException e) {
			System.err.println("sql exception in unregister");
			System.err.println(e);
			e.printStackTrace();
			System.exit(2); 		
		}

		 
	}	

	public static String[][] resultToArray(ResultSet rslt) {
		int rowSize = 0;
		int columnSize = 0;
		String[][] arr = null;
		try {
			try {
				rslt.last();
				rowSize = rslt.getRow();
				rslt.beforeFirst();
			} catch (SQLException e) {
				System.err.println("sql exception in getting rowCount");
				System.err.println(e);
				System.exit(2); 
			}
			if (rowSize != 0) {
				ResultSetMetaData rsmd = rslt.getMetaData();
				columnSize = rsmd.getColumnCount();
				arr = new String[rowSize][columnSize];
				int i = 0;
		        while(rslt.next() && i < rowSize)
		        {
		            for(int j=0;j<columnSize;j++){
		                arr[i][j] = rslt.getString(j+1);
		            }
		            i++;                    
		        }
		        rslt.close();
		        // for (i=0; i<rowSize;i++) {
		        // 	for ( int j=0; j<columnSize; j++ ){
		        // 		System.out.print(arr[i][j] + " ");
		        // 	}
		        // 	System.out.println();
		        // }
	    	}

		} catch (SQLException e) {
			System.err.println("sql exception in parsing result");
			System.err.println(e);
			System.exit(2); 			
		}
		return arr;
	}
}