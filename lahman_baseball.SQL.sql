SELECT MIN(year) as min_year, MAX(year) as max_year
FROM homegames

SELECT MAX(year)
FROM homegames

SELECT MAX(debut)
FROM people

SELECT MIN(debut), MAX(debut)
FROM people
--Question 1--



SELECT namelast, namefirst, height, appearances.g_all as games_played, appearances.teamid as team
FROM people
INNER JOIN appearances
ON people.playerid = appearances.playerid
WHERE height IS NOT null
ORDER BY height
LIMIT 1;


SELECT DISTINCT teams.name, namelast, namefirst, height, appearances.g_all as games_played, appearances.yearid as year
FROM people
INNER JOIN appearances
ON people.playerid = appearances.playerid
INNER JOIN teams
ON appearances.teamid = teams.teamid
WHERE height IS NOT null
ORDER BY height, namelast
LIMIT 1;


WITH shortest_player AS (SELECT *
						FROM people
						ORDER BY height
						LIMIT 1),
sp_total_games AS (SELECT *
				  FROM shortest_player
				  LEFT JOIN appearances
				  USING(playerid))
SELECT DISTINCT(name), namelast, namefirst, height, g_all as games_played, sp_total_games.yearid
FROM sp_total_games
LEFT JOIN teams
USING(teamid);




--Question 2--


SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win
FROM teams
WHERE wswin IS NOT null
AND yearid BETWEEN 1969 AND 2017
AND wswin = 'Y'
ORDER BY wins
LIMIT 1;


SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win
FROM teams
WHERE wswin IS NOT null
AND yearid BETWEEN 1969 AND 2017
AND wswin = 'Y'
AND yearid NOT BETWEEN '1981' AND '1981'
ORDER BY wins
LIMIT 1;

SELECT yearid,
	MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 and 2016
AND wswin = 'Y'
GROUP BY yearid
INTERSECT
SELECT yearid,
	MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 and 2016
GROUP BY yearid
ORDER BY yearid;




WITH games_wins AS (SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win,
			RANK() OVER (PARTITION BY yearid ORDER BY w DESC)
			FROM teams
			WHERE wswin IS NOT NULL
			AND yearid BETWEEN 1970 and 2016),
winners AS (SELECT *
		FROM games_wins
		WHERE rank = 1
		AND world_series_win = 'Y')
SELECT ROUND((COUNT(*)::numeric/(2016-1970)::numeric)*100, 2) as most_wins_won_percentage
FROM winners;

WITH ws_winners AS (SELECT yearid,
						MAX(w)
					FROM teams
					WHERE yearid BETWEEN 1970 and 2016
					AND wswin = 'Y'
					GROUP BY yearid
					INTERSECT
					SELECT yearid,
						MAX(w)
					FROM teams
					WHERE yearid BETWEEN 1970 and 2016
					GROUP BY yearid
					ORDER BY yearid)
SELECT (COUNT(ws.yearid)/COUNT(t.yearid)::float)*100 AS percentage
FROM teams as t LEFT JOIN ws_winners AS ws ON t.yearid = ws.yearid
WHERE t.wswin IS NOT NULL
AND t.yearid BETWEEN 1970 AND 2016;


--Question 7--



WITH games_wins AS (SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win,
			RANK() OVER (PARTITION BY yearid ORDER BY w DESC)
			FROM teams
			WHERE wswin IS NOT NULL
			AND yearid BETWEEN 1970 and 2016),
winners AS (SELECT *
		FROM games_wins
		WHERE rank = 1
		AND world_series_win = 'Y')
SELECT ROUND((COUNT(*)::numeric/(2016-1970)::numeric)*100, 2) as most_wins_won_percentage
FROM winners;		
		
SELECT name as team_name, yearid as year, w as wins, wswin as world_series_win,
			RANK() OVER (PARTITION BY yearid ORDER BY w DESC)
			FROM teams
			WHERE wswin IS NOT NULL
			AND yearid BETWEEN 1970 and 2016
			GROUP BY RANK, name, yearid, w, wswin
			
			
SELECT *
FROM pitching
LIMIT 5;

SELECT namelast, namefirst, throws as throwing_hand, pitching.w as wins, pitching.l as losses
FROM people
INNER JOIN pitching
ON people.playerid = pitching.playerid
WHERE throws IS NOT null
ORDER BY w DESC
LIMIT 10;


SELECT
	COUNT(CASE WHEN throws = 'R' THEN 'right handed' END) as throws_right,
	COUNT(CASE WHEN throws = 'L' THEN 'left handed' END) as throws_left
FROM people
WHERE throws IS NOT null

SELECT *
FROM awardsplayers
WHERE awardid like 'Cy Young%'


SELECT namelast, namefirst, awardsplayers.awardid, throws as throwing_hand, pitching.w as wins, pitching.l as losses
FROM people
INNER JOIN pitching
ON people.playerid = pitching.playerid
INNER JOIN awardsplayers
ON pitching.playerid = awardsplayers.playerid
WHERE throws IS NOT null
AND awardid like 'Cy Young%'
AND throws like 'R'
ORDER BY w DESC
LIMIT 10;

SELECT namelast, namefirst, awardsplayers.awardid, throws as throwing_hand, pitching.w as wins, pitching.l as losses
FROM people
INNER JOIN pitching
ON people.playerid = pitching.playerid
INNER JOIN awardsplayers
ON pitching.playerid = awardsplayers.playerid
WHERE throws IS NOT null
AND awardid like 'Cy Young%'
AND throws like 'L'
ORDER BY w DESC
LIMIT 10;

SELECT
	COUNT(CASE WHEN throws = 'R' THEN 'right handed' END) as throws_right,
	COUNT(CASE WHEN throws = 'L' THEN 'left handed' END) as throws_left
FROM people
WHERE throws IS NOT null

SELECT namelast, namefirst, COUNT(awardsplayers.awardid), throws as throwing_hand, pitching.w as wins, pitching.l as losses
FROM people
INNER JOIN pitching
ON people.playerid = pitching.playerid
INNER JOIN awardsplayers
ON pitching.playerid = awardsplayers.playerid
WHERE throws IS NOT null
AND awardid like 'Cy Young%'
AND throws like 'L'
ORDER BY w DESC
LIMIT 10;

-------------
SELECT distinct concat(p.namefirst, ' ', p.namelast) as name, sc.schoolname,
  sum(sa.salary)
  OVER (partition by concat(p.namefirst, ' ', p.namelast)) as total_salary
  FROM (people p JOIN collegeplaying cp ON p.playerid = cp.playerid)
  JOIN schools sc ON cp.schoolid = sc.schoolid
  JOIN salaries sa ON p.playerid = sa.playerid
  where cp.schoolid = 'vandy'
  group by name, schoolname, sa.salary, sa.yearid
  ORDER BY total_salary desc
--Question 3--

------------
SELECT
	CASE WHEN pos LIKE 'OF' THEN 'Outfield'
		WHEN pos LIKE 'C' THEN 'Battery'
		WHEN pos LIKE 'P' THEN 'Battery'
		ELSE 'Infield' END AS fielding_group,
	SUM(po) AS putouts
FROM fielding
WHERE yearid = 2016
GROUP BY fielding_group;

--Question 4--

SELECT yearid/10 * 10 AS decade, 
	ROUND(((SUM(so)::float/SUM(g))::numeric), 2) AS avg_so_per_game,
	ROUND(((SUM(so)::float/SUM(ghome))::numeric), 2) AS avg_so_per_ghome
FROM teams
WHERE yearid >= 1920 
GROUP BY decade
----------------
--question 5--
SELECT yearid/10*10 as decade, ROUND(AVG(HR/g), 2) as avg_HR_per_game,ROUND(AVG(so/g), 2) as avg_so_per_game
FROM teams
WHERE yearid>=1920
GROUP BY decade
ORDER BY decade

--question 5--
-------------
SELECT Concat(namefirst,' ',namelast), batting.yearid, ROUND(MAX(sb::decimal/(cs::decimal+sb::decimal))*100,2) as sb_success_percentage
FROM batting
INNER JOIN people on batting.playerid = people.playerid
WHERE yearid = '2016'
AND (sb+cs) >= 20
GROUP BY namefirst, namelast, batting.yearid
ORDER BY sb_success_percentage DESC;

--question 6--
--------------
SELECT DISTINCT p.park_name, h.team,
	(h.attendance/h.games) as avg_attendance, t.name		
FROM homegames as h JOIN parks as p ON h.park = p.park
LEFT JOIN teams as t on h.team = t.teamid AND t.yearid = h.year
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;


--question 8--
--------------
WITH manager_both AS (SELECT playerid, al.lgid AS al_lg, nl.lgid AS nl_lg,
					  al.yearid AS al_year, nl.yearid AS nl_year,
					  al.awardid AS al_award, nl.awardid AS nl_award
	FROM awardsmanagers AS al INNER JOIN awardsmanagers AS nl
	USING(playerid)
	WHERE al.awardid LIKE 'TSN%'
	AND nl.awardid LIKE 'TSN%'
	AND al.lgid LIKE 'AL'
	AND nl.lgid LIKE 'NL')
	
SELECT DISTINCT(people.playerid), namefirst, namelast, managers.teamid,
		managers.yearid AS year, managers.lgid
FROM manager_both AS mb LEFT JOIN people USING(playerid)
LEFT JOIN salaries USING(playerid)
LEFT JOIN managers USING(playerid)
WHERE managers.yearid = al_year OR managers.yearid = nl_year;


--question 9--

-----------------
--Open Ended Questions--


