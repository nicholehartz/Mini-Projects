/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, and revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name 
FROM Facilities 
WHERE membercost > 0;


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) 
FROM Facilities 
WHERE membercost > 0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance 
FROM Facilities 
WHERE membercost < 0.2*(monthlymaintenance);


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * 
FROM Facilities 
WHERE facid IN (1, 5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, 
	monthlymaintenance, 
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	WHEN monthlymaintenance <= 100 THEN 'cheap' END AS monthlymaintenancecost
FROM Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname, joindate 
FROM Members 
ORDER BY joindate DESC;


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT(m.surname, ', ', m.firstname) AS membername, f.name, f.facid
FROM Members AS m
INNER JOIN Bookings AS b
ON m.memid = b.memid
Inner Join Facilities AS f
ON b.facid = f.facid
WHERE f.name LIKE 'Tennis Court%'
ORDER BY membername;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name AS facilityname, 
	CASE WHEN m.memid != 0
		THEN CONCAT(m.surname, ', ', m.firstname) 
	ELSE 'Guest' END AS clientname,
	CASE WHEN m.memid != 0
		THEN (b.slots * f.membercost)
	ELSE (b.slots * f.guestcost) END AS cost
FROM Members AS m 
INNER JOIN Bookings AS b
ON m.memid = b.memid
INNER JOIN Facilities AS f
ON b.facid = f.facid
WHERE starttime LIKE '2012-09-14%'
HAVING cost > 30
ORDER BY cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT facilityname, clientname, cost
FROM 
	(SELECT
		f.name AS facilityname, 
     	CASE WHEN m.memid != 0
			THEN CONCAT(m.surname, ', ', m.firstname) 
		ELSE 'Guest' END AS clientname,
		CASE WHEN m.memid != 0
			THEN (b.slots * f.membercost)
		ELSE (b.slots * f.guestcost) END AS cost
     FROM Bookings as b
     JOIN Facilities AS f
     ON b.facid = f.facid
     JOIN Members AS m
     ON b.memid = m.memid
     WHERE starttime LIKE '2012-09-14%') AS subquery
HAVING cost > 30
ORDER BY cost DESC;


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT f.name AS facilityname, 
	SUM(CASE WHEN m.memid != 0 
		THEN (b.slots * f.membercost) 
	ELSE (b.slots * f.guestcost) END) AS Revenue 
FROM Members AS m  
INNER JOIN Bookings AS b 
ON m.memid = b.memid 
INNER JOIN Facilities AS f 
ON b.facid = f.facid 
GROUP BY facilityname 
HAVING Revenue < 1000 
ORDER BY Revenue DESC

import sqlite3 as sql
import pandas as pd
con = sql.connect('country_club.db')
code10 = "SELECT f.name AS facilityname, SUM(CASE WHEN m.memid != 0 THEN (b.slots * f.membercost) ELSE (b.slots * f.guestcost) END) AS Revenue FROM Members AS m  INNER JOIN Bookings AS b ON m.memid = b.memid INNER JOIN Facilities AS f ON b.facid = f.facid GROUP BY facilityname HAVING Revenue < 1000 ORDER BY Revenue DESC"
rs10 = con.execute(code10)
df10 = pd.DataFrame(rs10.fetchall())
df10.columns = [x[0] for x in rs10.description]
print(df10)
con.close()


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT DISTINCT 
	CASE WHEN B.memid != 0 
		THEN (B.surname || ', ' || B.firstname)  
	END AS member_name, 
	CASE WHEN A.memid !=0 
		THEN (A.surname || ', ' || A.firstname) 
	END AS recommending_member_name 
FROM Members AS A, Members AS B 
WHERE A.memid = B.recommendedby 
AND B.memid != 0 
ORDER BY member_name

import sqlite3 as sql
import pandas as pd
con = sql.connect('country_club.db')
code11 = "SELECT DISTINCT CASE WHEN B.memid != 0 THEN (B.surname || ', ' || B.firstname)  END AS member_name, CASE WHEN A.memid !=0 THEN (A.surname || ', ' || A.firstname) END AS recommending_member_name FROM Members AS A, Members AS B WHERE A.memid = B.recommendedby AND B.memid != 0 ORDER BY member_name"
rs11 = con.execute(code11)
df11 = pd.DataFrame(rs11.fetchall())
df11.columns = [x[0] for x in rs11.description]
print(df11)
con.close()


/* Q12: Find the facilities with their usage by member, but not guests */
SELECT f.name AS facility_name,
	CASE WHEN m.memid !=0 
		THEN CONCAT(m.surname, ', ', m.firstname) END AS member_name,
	ROUND(((b.slots * 30)/60), 1) AS hourly_usage
FROM Members AS m 
INNER JOIN Bookings AS b
ON m.memid = b.memid
INNER JOIN Facilities AS f
ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY b.memid, f.facid
ORDER BY member_name, facility_name;

import sqlite3 as sql
import pandas as pd
con = sql.connect('country_club.db')
code12 = "SELECT f.name AS facility_name, CASE WHEN m.memid !=0 THEN (m.surname || ', ' || m.firstname) END AS member_name, ((b.slots*30)/60.0) AS hourly_usage FROM Members AS m  INNER JOIN Bookings AS b ON m.memid = b.memid INNER JOIN Facilities AS f ON b.facid = f.facid WHERE b.memid != 0 GROUP BY b.memid, f.facid ORDER BY member_name, facility_name"
rs12 = con.execute(code12)
df12 = pd.DataFrame(rs12.fetchall())
df12.columns = [x[0] for x in rs12.description]
print(df12)
con.close()


/* Q13: Find the facilities usage by month, but not guests */
SELECT 
	CASE WHEN MONTH(starttime) = 7 
		THEN 'July' 
	WHEN MONTH(starttime) = 8 
		THEN 'August' 
	WHEN MONTH(starttime) = 9 
		THEN 'September' END AS month,  
	f.name AS facility_name, 
	((SUM(slots)*30)/60) AS hourly_usage 
FROM Members AS m  
INNER JOIN Bookings AS b 
ON m.memid = b.memid 
INNER JOIN Facilities AS f 
ON b.facid = f.facid 
WHERE b.memid != 0 
GROUP BY month, facility_name 
ORDER BY month, facility_name;

import sqlite3 as sql
import pandas as pd
con = sql.connect('country_club.db')
code13 = "SELECT CASE WHEN strftime('%m', starttime) = '07' THEN 'July' WHEN strftime('%m', starttime) = '08' THEN 'August' WHEN strftime('%m', starttime) = '09' THEN 'September' END AS month,  f.name AS facility_name, ((SUM(slots)*30)/60.0) AS hourly_usage FROM Members AS m  INNER JOIN Bookings AS b ON m.memid = b.memid INNER JOIN Facilities AS f ON b.facid = f.facid WHERE b.memid != 0 GROUP BY month, facility_name ORDER BY month, facility_name"
rs13 = con.execute(code13)
df13 = pd.DataFrame(rs13.fetchall())
df13.columns = [x[0] for x in rs13.description]
print(df13)
con.close()
