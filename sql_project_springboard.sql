/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT facid,
       name AS 'Facility Name',
       membercost
  FROM country_club.Facilities
 WHERE membercost <> 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( name ) 
FROM country_club.Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,
       name,
       membercost,
       monthlymaintenance,
       (membercost*100)/monthlymaintenance AS 'Ratio(%)'
  FROM country_club.Facilities
 WHERE ((membercost*100)/monthlymaintenance ) < 20

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
  FROM country_club.Facilities
 WHERE facid IN (1,5)
 
/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
       monthlymaintenance,
	   CASE  WHEN monthlymaintenance <= 100 THEN 'Cheap' 
             ELSE 'Expensive' END AS Label
  FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,
	   surname,
	   joindate
  FROM country_club.Members
WHERE joindate = (SELECT MAX(joindate) FROM country_club.Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/* Per the "Facilities" table, there are two Tennis courts (Tennis court 1 and Tennis court 2,
 and the facid for them is 0 and 1 respectively*/

SELECT DISTINCT (Bookings.memid),
       CONCAT(Members.firstname, ' ', Members.surname) AS Member_Name,
       Bookings.facid AS Facility_ID,
       Facilities.name AS Facility_Name
  FROM country_club.Bookings Bookings
      JOIN country_club.Members Members ON Members.memid=Bookings.memid
      JOIN country_club.Facilities Facilities ON Facilities.facid=Bookings.facid
 WHERE Bookings.facid  = 0 OR Bookings.facid  = 1
 ORDER BY  Member_Name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name AS Facility_Name,
       CONCAT(Member.firstname,' ',Member.surname) AS Member_Name,
	   DATE(Bookings.starttime) AS Booking_Date,
       Bookings.slots AS Slot,
      
       CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost*Bookings.slots
     		ELSE Facilities.membercost*Bookings.slots END AS Total_Cost
       
  FROM country_club.Bookings Bookings
       JOIN country_club.Members Member ON Member.memid=Bookings.memid
       JOIN country_club.Facilities Facilities  ON Facilities.facid=Bookings.facid
WHERE DATE(Bookings.starttime) = '2012-09-14'
HAVING Total_Cost > 30
ORDER BY Total_Cost DESC
 
/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.Facility_Name,
       sub.Member_Name,
       CASE WHEN sub.Mem_ID = 0 THEN sub.Guest_Fee*sub.Slots
     	   ELSE sub.Member_Fee*sub.Slots END AS Total_Pay
      
 FROM (
       SELECT Facilities.name AS Facility_Name,
              Bookings.memid as Mem_ID,
              CONCAT(Member.firstname,' ',Member.surname) AS Member_Name,
              Facilities.membercost AS Member_Fee,
              Facilities.guestcost AS Guest_Fee,
              Bookings.slots AS Slots
         FROM country_club.Bookings Bookings
            JOIN country_club.Members Member ON Member.memid=Bookings.memid
            JOIN country_club.Facilities Facilities  ON Facilities.facid=Bookings.facid
        WHERE DATE(Bookings.starttime) = '2012-09-14'
       ) sub   
HAVING Total_Pay > 30
ORDER BY Total_Pay DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT Facilities.name AS Facility_Name,
	   SUM(CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost*Bookings.slots
     	   ELSE Facilities.membercost*Bookings.slots END) 
           -3*Facilities.monthlymaintenance 
                       AS Revenue
      
 FROM country_club.Bookings Bookings
       JOIN country_club.Members Member ON Member.memid=Bookings.memid
       JOIN country_club.Facilities Facilities  ON Facilities.facid=Bookings.facid

GROUP BY Facilities.name
HAVING Revenue < 1000
ORDER BY Revenue DESC


  


