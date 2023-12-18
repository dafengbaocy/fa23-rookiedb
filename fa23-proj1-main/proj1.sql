-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;
DROP VIEW IF EXISTS CAcollege;
DROP VIEW IF EXISTS slg;
DROP VIEW IF EXISTS salary_statistics;
DROP VIEW IF EXISTS saha;
-- Question 0
CREATE VIEW q0(era)
AS
SELECT MAX(era)
FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
FROM people AS p
WHERE  p.weight>300-- replace this line
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
    FROM people
    WHERE  namefirst LIKE "% %"
    ORDER BY namefirst,namelast-- replace this line
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height), count(*) -- replace this line
  FROM people
  GROUP BY  birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
SELECT birthyear, avg(height), count(*) -- replace this line
FROM people
GROUP BY  birthyear
HAVING  avg(height)>70
ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, a.playerID, yearID
  FROM people AS p INNER JOIN HallofFame AS a
  ON p.playerID=a.playerID
  WHERE a.inducted = 'Y'
  ORDER BY  yearID DESC,a.playerID ASC-- replace this line
;

-- Question 2ii
CREATE VIEW CAcollege(playerid, schoolid)
AS
SELECT c.playerid, c.schoolid
FROM collegeplaying c INNER JOIN schools s
                                 ON c.schoolid = s.schoolid
WHERE s.schoolState = 'CA';

CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS

        SELECT namefirst, namelast, q.playerid, schoolid,yearID
        FROM q2i AS q  INNER JOIN  CAcollege AS c
        on q.playerid=c.playerid

        ORDER BY  yearID DESC,schoolid,q.playerid ASC-- replace this line
;

-- Question 2iii


CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
SELECT q.playerid, namefirst, namelast, schoolid
FROM q2i q LEFT OUTER JOIN collegeplaying c
                           ON q.playerid = c.playerid
ORDER BY q.playerid DESC, schoolid
;

-- Question 3i



CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerid, namefirst, namelast, b.yearid,((H+H2B+2*H3B+3*HR+0.0)/AB+0.0)  -- replace this line
  FROM people AS p NATURAL JOIN batting AS b
  WHERE b.AB > 50
    ORDER BY  ((H+H2B+2*H3B+3*HR+0.0)/AB+0.0) DESC ,b.yearid,b.playerid

    LIMIT 10;
;

-- Question 3ii

CREATE VIEW slg(playerid,   H,H2B,H3B,HR,AB)
AS
SELECT playerid,  SUM(H) ,SUM(H2B) ,SUM(H3B) , SUM(HR) ,SUM(AB )
FROM batting
GROUP BY playerid
;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT playerid, namefirst, namelast, ((H+H2B+2*H3B+3*HR+0.0)/AB+0.0)
FROM  slg s NATURAL JOIN people AS p
  WHERE s.AB > 50
ORDER BY  ((H+H2B+2*H3B+3*HR+0.0)/AB+0.0) DESC
LIMIT 10
-- replace this line
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, ((H+H2B+2*H3B+3*HR+0.0)/AB+0.0)
  FROM  slg s NATURAL JOIN people AS p
  WHERE s.AB > 50 AND ((H+H2B+2*H3B+3*HR+0.0)/AB+0.0)>
                      (
      SELECT ((H+H2B+2*H3B+3*HR+0.0)/AB+0.0)
      FROM slg
      WHERE slg.playerid="mayswi01"
      )


    ORDER BY  ((H+H2B+2*H3B+3*HR+0.0)/AB+0.0) DESC
-- replace this line
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, min(salary), max(salary), avg(salary)
    FROM salaries AS s
 GROUP BY  yearid
ORDER BY yearid
-- replace this line
;
-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);
-- Question 4ii


CREATE VIEW q4ii(binid, low, high, count)
AS
SELECT binid, 507500.0+binid*3249250,3756750.0+binid*3249250, count(*)
from binids,salaries
where (salary between 507500.0+binid*3249250 and 3756750.0+binid*3249250 )and yearID='2016'
group by binid
;

-- Question 4iii



CREATE VIEW salary_statistics(yearid, minsa, maxsa, avgsa)
AS
SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
FROM salaries
GROUP BY yearid
;


CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT a.yearid, a.minsa-b.minsa, a.maxsa-b.maxsa, a.avgsa-b.avgsa -- replace this line
FROM salary_statistics a INNER JOIN salary_statistics b
ON a.yearid-b.yearid=1
  GROUP BY a.yearid
ORDER BY  a.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, namefirst, namelast, MAX(salary), yearid
    FROM salaries s INNER JOIN  people p
    ON p.playerid=s.playerid
    GROUP BY yearid
    HAVING  yearid=2000 OR yearid=2001
ORDER BY  yearid
;
-- Question 4v

CREATE VIEW q4v(team, diffAvg) AS
SELECT a.teamid, MAX(s.salary) - MIN(s.salary)
FROM allstarfull a INNER JOIN salaries s
                              ON a.playerid = s.playerid AND a.yearid = s.yearid
WHERE s.yearid = 2016
GROUP BY a.teamid

;

