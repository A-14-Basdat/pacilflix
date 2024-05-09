import uuid

from django.db import connection
from django.shortcuts import render, redirect
from collections import namedtuple

def show_beli(request):
   return render(request, "beli.html")



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

def show_langganan(request):
   data = query(
        f"""
        SELECT nama, harga, resolusi_layar, STRING_AGG(dukungan_perangkat, ', ')
        FROM PAKET, DUKUNGAN_PERANGKAT
        WHERE PAKET.nama = DUKUNGAN_PERANGKAT.nama_paket
        GROUP BY PAKET.nama;
        """
    )

   context = {
        "data": data
    }
   print(data)
   
   return render(request, "langganan.html", context)

# SELECT P.id_brand, B.nama, STRING_AGG(BEL.nama, ', ') AS nama_pembeli
# FROM PEMBELI BEL, BRAND B, PRODUK P, TRANSAKSI T, TRANSAKSI_PRODUK TP
# WHERE BEL.id_pembeli = T.id_pembeli 
# AND T.id_transaksi = TP. id_transaksi
# AND TP.id_produk = P.id_produk
# AND P.id_brand = B.id_brand
# GROUP BY P.id_brand, B.nama;