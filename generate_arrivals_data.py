from datetime import datetime
import math
import random
import json
import os
import psycopg2


def random_cpt(is_main):
    r = random.random()
    if is_main:
        if r < 0.05:
            return "99282"
        elif r < 0.3:
            return "99283"
        elif r < 0.75:
            return "99284"
        elif r < 0.92:
            return "99285"
        else:
            return "99291"
    else:
        if r < 0.15:
            return "99282"
        elif r < 0.75:
            return "99283"
        else:
            return "99284"


def random_dow():
    r = random.random()
    if r < 0.16:
        return 1
    elif r < 0.315:
        return 2
    elif r < 0.46:
        return 3
    elif r < 0.605:
        return 4
    elif r < 0.75:
        return 5
    elif r < 0.875:
        return 6

    return 0


def random_rvus(cpt):
    r = random.random()
    if cpt == "99282":
        return 1.0 + 1.0 * r
    elif cpt == "99282":
        return 1.4 + 1.5 * r
    elif cpt == "99282":
        return 2.6 + 2.5 * r
    elif cpt == "99282":
        return 3.8 + 3.5 * r

    return 4.5 + 4 * r


def interpolate_arrivals_curve(minute_of_day, factor):
    values = [6, 3.5, 3.5, 2.5, 3, 4, 6, 8, 9, 12, 17, 21, 23, 24, 23, 21, 22, 21.5, 23, 22, 19, 13, 11, 7, 6]
    hod = math.floor(minute_of_day / 60.0)
    portion_of_hour = (minute_of_day % 60) / 60.0
    return math.floor(factor * 5.0 * (values[hod] * (1 - portion_of_hour) + values[hod + 1] * portion_of_hour))


def generate_test_data(department_id, scaling_factor, is_main, cur, conn):
    for i in range(0, 1440):
        arrivals_to_generate = interpolate_arrivals_curve(i, scaling_factor)
        for j in range(0, arrivals_to_generate):
            cpt = random_cpt(is_main)
            rvus = random_rvus(cpt)
            wk = math.floor(random.random() * 54.0)
            dow = random_dow()
            inst = 1640476800 + 604800 * wk + 86400 * dow + i * 60
            dtm = datetime.utcfromtimestamp(inst)
            cur.execute(
                f"INSERT INTO arrivals (arrival_datetime, rvus, cpt, age, department_id) VALUES ('{dtm}', '{rvus}', '{cpt}', 0, '{department_id}')")
    conn.commit()


# Use environment variables for sensitive information (RDS credentials)
DB_HOST = os.environ['DB_HOST']
DB_NAME = os.environ['DB_NAME']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_PORT = os.environ.get('DB_PORT', '5432')


def lambda_handler():
    # Connect to the PostgreSQL database
    conn = None
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            port=DB_PORT
        )
        cur = conn.cursor()

        cur.execute(
            "SELECT d.id FROM departments AS d WHERE d.department_name = 'Main ED' AND d.id NOT IN (SELECT DISTINCT ar.department_id FROM arrivals AS ar)")

        rv_mains = cur.fetchall()

        for row in rv_mains:
            dept_id = row[0]
            factor = 0.5 + random.random()
            generate_test_data(dept_id, factor, True, cur, conn)

        cur.execute(
            "SELECT d.id FROM departments AS d WHERE d.department_name != 'Main ED' AND d.id NOT IN (SELECT DISTINCT ar.department_id FROM arrivals AS ar)")

        rv_else = cur.fetchall()

        for row in rv_else:
            dept_id = row[0]
            factor = 0.2 + random.random() * 0.3
            generate_test_data(dept_id, factor, False, cur, conn)

        cur.close()

        return {
            'statusCode': 200,
            'body': json.dumps('Data read and written successfully')
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }

    finally:
        if conn:
            conn.close()


lambda_handler()
