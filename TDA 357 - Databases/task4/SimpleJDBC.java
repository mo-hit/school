/*
 * Adapted from:
 *
 * http://infolab.stanford.edu/~ullman/fcdb/oracle/or-jdbc.html
 * http://infolab.stanford.edu/~ullman/fcdb/oracle/SimpleJDBC.java
 *
 * This sample shows how to connect and compile a JDBC program
 * 
 * To run this program you need to:
 *  1) Copy it to your directory
 *  2) Fill in your username and password
 *  3) Compile by typing:
 *       javac -classpath /chalmers/sw/sup64/oracle_client-11.2.0.3/product/11.2.0/client_1/inventory/Scripts/ext/jlib/ojdbc5.jar SimpleJDBC.java
 *  4) Run by typing 
 *       java -classpath /chalmers/sw/sup64/oracle_client-11.2.0.3/product/11.2.0/client_1/inventory/Scripts/ext/jlib/ojdbc5.jar:. SimpleJDBC
 *
*/

// You need to import the java.sql package to use JDBC
import java.sql.*;

class SimpleJDBC
{
  public static void main (String args [])
       throws SQLException
  {
    // Load the Oracle JDBC driver
    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());

    // Connect to the database
    // You must put a database name after the @ sign in the connection URL.
    // You can use either the fully specified SQL*net syntax or a short cut
    // syntax as <host>:<port>:<sid>.
    Connection conn =
      DriverManager.getConnection ("jdbc:oracle:thin:@db.student.chalmers.se:1521/kingu.ita.chalmers.se",
				   "htda357_091", "htda357_091");

    // Create a Statement
    Statement stmt = conn.createStatement ();

    // Select the table names from the user_tables
    ResultSet rset = stmt.executeQuery ("select TABLE_NAME from USER_TABLES");

    // Iterate through the result and print out the table names
    while (rset.next ())
      System.out.println (rset.getString (1));
  }
}
