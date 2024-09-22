-- FUNCTION: public.generate_all_test_data()

-- DROP FUNCTION IF EXISTS public.generate_all_test_data();

CREATE OR REPLACE FUNCTION public.generate_all_test_data(
	)
    RETURNS void
    LANGUAGE 'plpython3u'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
import random

plpy.execute("SELECT generate_test_departments()")

rv_mains = plpy.execute("SELECT d.id FROM departments AS d WHERE d.department_name = 'Main ED' AND d.id NOT IN (SELECT DISTINCT ar.department_id FROM arrivals AS ar)")

for i in range(0, len(rv_mains)):
	department_id = rv_mains[i]["id"]
	factor = 0.5 + random.random()
	is_main = True
	plpy.execute(f"SELECT generate_test_data('{department_id}', {factor}, {is_main})")

rv_else = plpy.execute("SELECT d.id FROM departments AS d WHERE d.department_name != 'Main ED' AND d.id NOT IN (SELECT DISTINCT ar.department_id FROM arrivals AS ar)")

for i in range(0, len(rv_else)):
	department_id = rv_else[i]["id"]
	factor = 0.2 + random.random() * 0.3
	is_main = False
	plpy.execute(f"SELECT generate_test_data('{department_id}', {factor}, {is_main})")

$BODY$;

ALTER FUNCTION public.generate_all_test_data()
    OWNER TO robertpatton;
