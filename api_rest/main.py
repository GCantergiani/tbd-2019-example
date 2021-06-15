import sqlite3
import argparse
import configparser
import logging
import names

from random import randrange
from flask import Flask, request, jsonify
from flask_restful import Resource, Api
from sqlalchemy import create_engine

app = Flask(__name__)
api = Api(app)

logger = logging.getLogger(__name__ if __name__ != '__main__' else __package__)

NAME_DATABASE = 'example.db'

class Digits(Resource):
    def get(self):
        return {'examples': ['1','2','3']}

class Students(Resource):

    def get(self):
        db_connect = create_engine('sqlite:///{}'.format(NAME_DATABASE))
        conn = db_connect.connect()
        query = conn.execute('SELECT FIRST_NAME, LAST_NAME, AGE, TYPE_ID FROM STUDENT')

        result = {'data': [dict(zip(tuple(query.keys()), i)) for i in query.cursor]}
        return jsonify(result)

    def post(self):
        json_data = request.get_json(force=True)
        id_user = json_data['id_user']
        id_type = json_data['id_type']

        db_connect = create_engine('sqlite:///{}'.format(NAME_DATABASE))
        conn = db_connect.connect()
        query = conn.execute(f"UPDATE STUDENT SET TYPE_ID = {id_type} WHERE ID = {id_user}")




api.add_resource(Digits, '/digits')
api.add_resource(Students, '/students')


def create_db_w_examples():

    conn = sqlite3.connect(NAME_DATABASE)
    cursor = conn.cursor()

    cursor.execute("DROP TABLE IF EXISTS STUDENT")
    cursor.execute("DROP TABLE IF EXISTS TYPE")
    conn.commit()

    #Creating table as per requirement+
    ddl_type = '''
        CREATE TABLE TYPE(
                ID INT NOT NULL,
                VALUE CHAR(20) NOT NULL
            )
    '''

    ddl_query_student ='''
        CREATE TABLE STUDENT(
            ID INT,
            FIRST_NAME CHAR(20) NOT NULL,
            LAST_NAME CHAR(20),
            AGE INT,
            TYPE_ID INT,
            FOREIGN KEY(TYPE_ID) REFERENCES TYPE(ID)
        )
    '''

    cursor.execute(ddl_type)
    cursor.execute(ddl_query_student)

    logger.info('Students table created ...')
    conn.commit()

    for x in range(100):

        logger.debug('Inserting {} student...'.format(x))
        
        insert_query = '''
            INSERT INTO STUDENT
            VALUES({}, '{}', '{}', {}, NULL)
        '''.format(x,
                   names.get_first_name(), 
                   names.get_last_name(),
                   randrange(100))
        
        cursor.execute(insert_query)

        conn.commit()

    for x in range(10):
        logger.debug('Inserting {} types...'.format(x))
        insert_query = '''
            INSERT INTO TYPE
            VALUES({type}, type_'{type}')
        '''.format(type=x)


    conn.close()


if __name__ == '__main__':

    logging.basicConfig(
        level='DEBUG',
        format='%(asctime)-15s %(name)-20s %(levelname)-8s %(message)s')

    parser = argparse.ArgumentParser(description='')

    parser.add_argument('--create-db',
                        dest='create_db', 
                        action='store_true',
                        required=False)

    args = parser.parse_args()

    if args.create_db:
        create_db_w_examples()

    app.run(port='5000')