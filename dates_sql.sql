--
SELECT (SYSDATE -365 +(LEVEL -1)) AS DATES
FROM DUAL
CONNECT BY LEVEL <= (SYSDATE-(SYSDATE -365));

SELECT (TO_DATE('01-04-2015','DD-MM-YYYY') + LEVEL -1) AS day
FROM dual
CONNECT BY LEVEL <= (TO_DATE('01-05-2015','DD-MM-YYYY') - TO_DATE('01-04-2015','DD-MM-YYYY') +1);

SELECT (TO_DATE(start_date,'date-format') + LEVEL -1) AS day
FROM dual
CONNECT BY LEVEL <= (TO_DATE(end_date,'date-format') - TO_DATE(start_date,'date-format') +1);

