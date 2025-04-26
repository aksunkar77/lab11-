import psycopg2
import csv

conn = psycopg2.connect(
    dbname="PhoneBook",
    user="postgres",
    password="Aksu",
    host="localhost",
    port="5432"
)
cur = conn.cursor()


def insert_from_csv(filename):
    with open(filename, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            cur.execute("CALL insert_or_update_user(%s, %s);", 
                        (row['username'], row['phone']))
    conn.commit()

def insert_from_console():
    name = input("Enter name: ")
    phone = input("Enter phone (format 000-000-0000): ")
    cur.execute("CALL insert_or_update_user(%s, %s);", (name, phone))
    conn.commit()

def update_data():
    name = input("Enter username to update: ")
    new_phone = input("Enter new phone (format 000-000-0000): ")
    cur.execute("CALL insert_or_update_user(%s, %s);", (name, new_phone))
    conn.commit()

def search_by_pattern():
    pattern = input("Search pattern (name or phone part): ")
    cur.execute("SELECT * FROM search_phonebook(%s);", (pattern,))
    results = cur.fetchall()
    for row in results:
        print(row)

def get_paginated_users():
    limit = int(input("Enter how many users to show: "))
    offset = int(input("Enter offset: "))
    cur.execute("SELECT * FROM get_users_paginated(%s, %s);", (limit, offset))
    results = cur.fetchall()
    for row in results:
        print(row)

def delete_user():
    value = input("Enter username or phone to delete: ")
    cur.execute("CALL delete_user(%s);", (value,))
    conn.commit()

def main():
    while True:
        print("\nPhoneBook Menu:")
        print("1. Insert from CSV")
        print("2. Insert from console")
        print("3. Update user")
        print("4. Search by pattern")
        print("5. Get paginated users")
        print("6. Delete user")
        print("0. Exit")

        choice = input("Choose option: ")

        if choice == "1":
            filename = input("Enter CSV filename: ")
            insert_from_csv(filename)
        elif choice == "2":
            insert_from_console()
        elif choice == "3":
            update_data()
        elif choice == "4":
            search_by_pattern()
        elif choice == "5":
            get_paginated_users()
        elif choice == "6":
            delete_user()
        elif choice == "0":
            break
        else:
            print("Invalid option!")

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
