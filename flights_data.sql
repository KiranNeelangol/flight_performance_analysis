SELECT * FROM flights
ORDER BY id;

ALTER TABLE flights
RENAME COLUMN name to flight_name

ALTER TABLE flights
RENAME COLUMN flight to flight_no


DELETE FROM flights
WHERE id NOT IN(
	SELECT MIN(ID)
	FROM flights
	GROUP BY flight, dep_time, arr_time);
-- Delete all the duplicate rows

ALTER TABLE flights
ALTER COLUMN dep_time TYPE TIME
USING CASE
	WHEN dep_time = 2400 THEN TIME '00:00:00'
	WHEN dep_time IS NULL OR dep_time = 0 THEN NULL
	WHEN dep_time > 2359 OR dep_time < 0 THEN NULL
	ELSE TO_TIMESTAMP(LPAD(dep_time::text, 4, '0'), 'HH24MI')::TIME
END;
-- Converting Numeric dep_time to time format (640 to 6:40)

ALTER TABLE flights
ALTER COLUMN arr_time TYPE TIME
USING CASE
	WHEN arr_time = 2400 then TIME '00:00:00'
	WHEN arr_time is null or arr_time = 0 THEN NULL
	WHEN arr_time > 2359 or arr_time < 0 THEN NULL
	ELSE TO_TIMESTAMP(LPAD(arr_time::text, 4, '0'), 'HH24MI')::TIME
END;
-- Converting Numeric arr_time to time format.

ALTER TABLE flights
ALTER COLUMN sched_dep_time TYPE TIME
USING CASE
	WHEN sched_dep_time = 2400 then TIME '00:00:00'
	ELSE TO_TIMESTAMP(LPAD(sched_dep_time::text, 4, '0'), 'HH24MI')::TIME
END;
-- Converting Numeric sched_dep_time to time format.

ALTER TABLE flights
ALTER COLUMN sched_arr_time TYPE TIME
USING CASE
	WHEN sched_arr_time = 2400 THEN TIME '00:00:00'
	ELSE TO_TIMESTAMP(LPAD(sched_arr_time::text, 4, '0'), 'HH24MI')::TIME
END;
-- Converting Numeric sched_arr_time to time format.

ALTER TABLE flights
ADD COLUMN cancelled_flights BOOLEAN;
UPDATE flights
SET cancelled_flights = CASE
				WHEN dep_time IS NULL and arr_time IS NULL THEN TRUE
				ELSE FALSE
				END;
-- Creating a new column to conclude the cancelled flights.

UPDATE flights
SET arr_time = dep_time + (sched_arr_time - sched_dep_time)
WHERE arr_time IS NULL
	AND dep_time IS NOT NULL
	AND sched_dep_time IS NOT NULL
	AND sched_arr_time IS NOT NULL;
-- Statistically filling the null arr_time when the dep_time is present.

UPDATE flights f1
SET tailnum = (
	SELECT f2.tailnum 
	FROM flights f2
	WHERE f2.flight_no = f1.flight_no
	AND f2.tailnum IS NOT NULL
	LIMIT 1
)
WHERE f1.tailnum IS NULL;
-- Statistically filling null tailnums comparing other rows with the same flight_no.

SELECT dep_time, arr_time, cancelled_flights
FROM flights
WHERE dep_time IS NULL AND arr_time IS NULL;
-- Confirming the cancelled_flights is working correctly.


SELECT flight_name, COUNT(*) AS total_flights
FROM flights
WHERE dep_time IS NOT NULL
GROUP By flight_name
ORDER BY total_flights DESC;
-- 'United Air Lines Inc' has the most flights(56990) whereas 'SkyWest Airlines Inc' has the least
--  flights(28).


SELECT flight_name, ROUND(AVG(dep_delay),2) AS avg_dep_delay
FROM flights
WHERE dep_delay IS NOT NULL
GROUP BY flight_name
ORDER BY avg_dep_delay DESC;
-- Frontier Air Lines Inc. also has the most avg departure delay(minutes) whereas
-- US Airways Inc. has the lowest avg departure delay.

SELECT flight_name, ROUND(AVG(arr_delay),2) AS avg_arr_delay
FROM flights
WHERE arr_delay IS NOT NULL
GROUP BY flight_name
ORDER BY avg_arr_delay DESC;
-- Frontier airlines has the most avg arrival delay(minutes) whereas 
-- Alaska Airlines Inc. has the least avg arrival delay.

SELECT origin, dest, COUNT(*) AS most_flights
FROM flights
GROUP BY origin, dest
ORDER BY most_flights DESC;
-- Here we can see that New York to Los Angeles is the most busiest route.

SELECT DATE_TRUNC('month', time_hour) AS months,
	   COUNT(*) AS total_flights
FROM flights
GROUP BY months
ORDER BY months;
SELECT 
	DATE_TRUNC('month', time_hour) AS months,
	COUNT(*) AS total_flights,
	LAG(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', time_hour)) AS prev_mon_flights,
	ROUND( 
			((COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month',time_hour)))::NUMERIC
	        / LAG(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month',time_hour))) * 100, 
			2) AS MoM_pct
FROM flights
GROUP BY DATE_TRUNC('month', time_hour)
ORDER BY months;
-- Month over Month growth change analysis.
-- As we can see March and October shown a substantial spike compared to their previous months respectively.


SELECT 
	DATE_TRUNC('month', time_hour) AS months,
	COUNT(*) AS total_flights
FROM flights
WHERE dep_time IS NOT NULL
GROUP BY months
ORDER BY total_flights desc;
-- OCT has the most no of flights whereas Feb has the least flights.


SELECT origin, dest, COUNT(*) AS total_flight
FROM flights
GROUP BY origin, dest
ORDER BY total_flight DESC;
--Busiest route is NY to LA followed by NY to ATL


SELECT 
	CASE WHEN arr_delay <=0 THEN 'On-Time' ELSE 'Delayed'
	END AS status,
	COUNT(*) AS total_flight
FROM flights
GROUP BY status;
-- On-Time vs Delayed flights

SELECT
	CASE
		WHEN EXTRACT(HOUR FROM sched_dep_time) BETWEEN 0 AND 5 THEN 'NIGHT(12am to 5 am)' 
		WHEN EXTRACT(HOUR FROM sched_dep_time) BETWEEN 6 AND 11 THEN 'MORNING(6am to 11am)'
		WHEN EXTRACT(HOUR FROM sched_dep_time) BETWEEN 12 AND 17 THEN 'AFTERNOON(12pm to 5 pm)'
		WHEN EXTRACT(HOUR FROM sched_dep_time) BETWEEN 18 AND 23 THEN 'EVENING(6pm t0 12 am)'
	END AS time_period,
	COUNT(*) AS total_flights,
	COUNT(*) FILTER (WHERE dep_delay > 60) AS most_delayed,
	ROUND(100 * COUNT(*) FILTER (WHERE dep_delay > 60) / COUNT(*), 2) AS delay_rate,
	ROUND(AVG(dep_delay)::NUMERIC, 2) AS avg_dep_delay_min,
	ROUND(AVG(arr_delay)::NUMERIC, 2) AS avg_arr_delay_min
FROM flights
WHERE dep_delay IS NOT NULL
GROUP BY time_period
ORDER BY most_delayed DESC;
-- 1) Here we can see that flights to delayed ratio is the most for the Evening flights than any other timezone,
-- 	  for arrival and departure as well making it the most delayed timezone.
-- 2) The afternoon timezone is facing 3 times more delay than morning timezone.
-- 3) As The night timezone doesn't have enough flights to conclude the insights,
--    but it shows promising average on time departure followed by 4 min early average arrival rate,
--    making it the ideal time for travel without getting delayed.

SELECT flight_name, 
       COUNT(*) as total_flights,
	   COUNT(*) FILTER(WHERE dep_delay > 15) AS delayed_flights,
	   ROUND(COUNT(*) FILTER(WHERE dep_delay > 15) * 100/ COUNT(*), 2) as delayed_pct,
	   ROUND(AVG(dep_delay)::NUMERIC, 2) as avg_delay
FROM flights
WHERE dep_delay IS NOT NULL
GROUP BY flight_name
ORDER BY delayed_pct desc;
-- 1) We can see that the ExpressJet Airlines Inc. has the highest delayed % at 31% 
-- 	  and Hawaiian Airlines with the least delayed % at 7%.
-- 2) Even after'United Air Lines Inc.' having 7000 flights more than 'Express JetAirlines Inc.',
--    it still has 10% less delayed rate.
-- 3) The Frontier Airlines Inc. has the highest average delay compared to all other airlines.


SELECT 
	ROUND(CORR(distance, arr_delay)::NUMERIC, 2) as corr_dep_delay,
	ROUND(CORR(distance, dep_delay)::NUMERIC, 2) as corr_arr_delay
FROM flights
WHERE distance IS NOT NULL
AND arr_delay IS NOT NULL;
-- As we can see that the correlation between distance and delay is symmetrical i.e ~0 .



