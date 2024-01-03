import os
from dotenv import load_dotenv
from pymongo import MongoClient


load_dotenv()


def get_database():
    """Get MongoDB database."""
    host = os.environ.get("MONGODB_HOST", "127.0.0.1")
    port = os.environ.get("MONGODB_PORT", "27017")
    user = os.environ.get("MONGODB_USER")
    password = os.environ.get("MONGODB_PASS")
    database = os.environ.get("MONGODB_DBNAME")
    # Provide the mongodb url to connect python to mongodb using pymongo
    connection_string = f"mongodb://{user}:{password}@{host}:{port}/"
    print(f"connection: {connection_string}")
    return MongoClient(connection_string)[database]


def insert_test(database, collection_name: str):
    collection = database[collection_name]
    item = {
        "_id" : "ru",
        "name" : "Russia",
        "exports" : {"foods": [{ "name": "chicken", "tasty": True }]},
    }
    delete_test(database, collection_name)
    collection.insert_one(item)


def delete_test(database, collection_name: str):
    collection = database[collection_name]
    collection.delete_one({"_id": "ru"})


def print_db(database, collection_name):
    collection = database[collection_name]
    for number, item in enumerate(collection.find()):
        print(f"{number}) {item}")


if __name__ == "__main__":   
    db = get_database()
    print("Database before:")
    print_db(db, "test")
    insert_test(db, "test")
    print("Database after insertion:")
    print_db(db, "test")