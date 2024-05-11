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

def show_langganan(request):
    pilihan = query(
        f"""
        SELECT nama, harga, resolusi_layar, STRING_AGG(dukungan_perangkat, ', ')
        FROM PAKET, DUKUNGAN_PERANGKAT
        WHERE PAKET.nama = DUKUNGAN_PERANGKAT.nama_paket
        GROUP BY PAKET.nama;
        """
    )

    riwayat = query(
        f"""
        SELECT *
        FROM TRANSACTION, PAKET
        WHERE TRANSACTION.username = '{request.session["username"]}'
        AND TRANSACTION.nama_paket = PAKET.nama
        ;
        """
    )

    aktif = query(
        f"""
        SELECT nama, harga, resolusi_layar, STRING_AGG(dukungan_perangkat, ', '), start_date_time, end_date_time
        FROM TRANSACTION, PAKET, DUKUNGAN_PERANGKAT
        WHERE TRANSACTION.username = '{request.session["username"]}'
        AND end_date_time > CURRENT_DATE
        AND start_date_time < CURRENT_DATE
        AND PAKET.nama = DUKUNGAN_PERANGKAT.nama_paket
        GROUP BY PAKET.nama, start_date_time, end_date_time;
        """
    )

    context = {
        "pilihan": pilihan,
        "riwayat": riwayat,
        "aktif": aktif
    }
    print(pilihan)
    print(riwayat)
    print(aktif)
   
    return render(request, "langganan.html", context)

def show_beli_basic(request):
    data = query(
        f"""
        SELECT nama, harga, resolusi_layar, STRING_AGG(dukungan_perangkat, ', ')
        FROM PAKET, DUKUNGAN_PERANGKAT
        WHERE PAKET.nama = 'basic'
        AND PAKET.nama = DUKUNGAN_PERANGKAT.nama_paket
        GROUP BY PAKET.nama;
        """
    )
   
    context = {
        "data": data
    }
   
    print(data, 'ini basic')
    return render(request, "beli.html", context)

def show_beli_premium(request):
    data = query(
        f"""
        SELECT nama, harga, resolusi_layar, STRING_AGG(dukungan_perangkat, ', ')
        FROM PAKET, DUKUNGAN_PERANGKAT
        WHERE PAKET.nama = 'premium'
        AND PAKET.nama = DUKUNGAN_PERANGKAT.nama_paket
        GROUP BY PAKET.nama;
        """
    )
   
    context = {
        "data": data
    }
   
    print(data, 'ini premium')
    return render(request, "beli.html", context)

def show_beli_standard(request):
    data = query(
        f"""
        SELECT nama, harga, resolusi_layar, STRING_AGG(dukungan_perangkat, ', ')
        FROM PAKET, DUKUNGAN_PERANGKAT
        WHERE PAKET.nama = 'standard'
        AND PAKET.nama = DUKUNGAN_PERANGKAT.nama_paket
        GROUP BY PAKET.nama;
        """
    )
   
    context = {
        "data": data
    }
   
    print(data, 'ini standar')
    return render(request, "beli.html", context)