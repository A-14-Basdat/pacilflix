import uuid

from django.db import connection
from django.shortcuts import render, redirect
from collections import namedtuple

def map_cursor(cursor):
    description = cursor.description
    query_result = namedtuple("Data", [col[0] for col in description])
    return [query_result(*row) for row in cursor.fetchall()]

# Basically, it returns a list of object/namedtuple. The way we access or retrieve the attributes is the same like OOP.
def query(query_str: str):
    result = []
    with connection.cursor() as cursor:
        try:
            cursor.execute(query_str)
            if query_str.strip().lower().startswith("select"):
                # Return hasil SELECT
                result = map_cursor(cursor)
            else:
                # Return jumlah row yang termodifikasi oleh INSERT, UPDATE, DELETE (int)
                result = cursor.rowcount
        except Exception as e:
            # Any
            result = e
    return result

def show_contributor(request):
   data = query(
        f"""
        SELECT *
        FROM contributors;
        """
    )

   context = {
        "data": data
    }
   print(len(data))
   
   return render(request, "contributor.html", context)

def show_pemain(request):
   print('masuk ke hsowpameins')
   data = query(
        f"""
        SELECT c.id, c.nama, c.jenis_kelamin, c.kewarganegaraan
        FROM contributors c
        JOIN pemain p ON c.id = p.id;
        """
    )

   context = {
        "data": data
    }
   print(len(data))
   
   return render(request, "contributor.html", context)

def show_penulis_skenario(request):

   data = query(
        f"""
        SELECT c.id, c.nama, c.jenis_kelamin, c.kewarganegaraan
        FROM contributors c
        JOIN penulis_skenario ps ON c.id = ps.id;
        """
    )

   context = {
        "data": data
    }
   print(len(data))
   
   return render(request, "contributor.html", context)

def show_sutradara(request):
   data = query(
        f"""
        SELECT c.id, c.nama, c.jenis_kelamin, c.kewarganegaraan
        FROM contributors c
        JOIN sutradara s ON c.id = s.id;
        """
    )

   context = {
        "data": data
    }
   print(len(data))
   
   return render(request, "contributor.html", context)

