-- procedures
CREATE OR REPLACE PROCEDURE procedure1 (percentage IN NUMBER,category IN VARCHAR,c OUT NUMBER,n OUT VARCHAR,ms OUT NUMBER) IS BEGIN UPDATE productsinfo
   SET msrp = msrp +((msrp*percentage) / 100)
WHERE productline = category;
SELECT productcode,
       productname,
       msrp INTO c,
       n,
       ms
FROM productsinfo
WHERE productline = category;
END;
/

CREATE OR REPLACE PROCEDURE procedure2(c out sys_refcursor) IS 
BEGIN
OPEN c 
for select employeeNumber from employees where rownum < 10;
END;
/

exec procedure2();
;
;

--example
CREATE OR REPLACE PROCEDURE myprocedure (retval IN OUT sys_refcursor) IS BEGIN open retval
FOR
SELECT productname
FROM products;
END;
/
SET SERVEROUTPUT ON
DECLARE myrefcur sys_refcursor;
productname products.productname % TYPE;
BEGIN myprocedure (myrefcur);
LOOP FETCH myrefcur INTO productname;
EXIT WHEN myrefcur % notfound;
dbms_output.put_line (productname);
END LOOP;
CLOSE myrefcur;
END;
/
execute myprocedue()
