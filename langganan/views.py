import uuid

from django.db import connection
from django.shortcuts import render, redirect
from collections import namedtuple
from datetime import datetime, timedelta


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
        AND TRANSACTION.nama_paket = PAKET.nama 
        AND end_date_time > CURRENT_DATE
        AND start_date_time <= CURRENT_DATE
        AND PAKET.nama = DUKUNGAN_PERANGKAT.nama_paket
        GROUP BY PAKET.nama, start_date_time, end_date_time;
        """
    )

    context = {
        "pilihan": pilihan,
        "riwayat": riwayat,
        "aktif": aktif
    }
    # print(pilihan)
    # print(riwayat)
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
   
    return render(request, "beli.html", context)

def bayar(request):
    print('atas')
    if request.method == "POST":
        username = request.session.get("username")
        start_date_time = datetime.now().date()
        end_date_time = start_date_time + timedelta(days=30)
        nama_paket = request.POST.get("nama_paket")
        metode_pembayaran = request.POST.get("metode_pembayaran")
        timestamp_pembayaran = datetime.now()

        print("masuk POST indent")
        query(
            f"""
            CREATE OR REPLACE FUNCTION beli_paket_langganan()
            RETURNS TRIGGER AS $$
            BEGIN
                -- Mengecek apakah ada paket aktif untuk pengguna tersebut
                IF EXISTS (
                    SELECT 1
                    FROM TRANSACTION
                    WHERE username = NEW.username
                    AND end_date_time >= CURRENT_DATE
                    AND start_date_time <= CURRENT_DATE
                ) THEN
                    -- Jika ada, lakukan update
                UPDATE TRANSACTION  
                SET end_date_time = NEW.end_date_time,
                    start_date_time = NEW.start_date_time,
                    nama_paket = NEW.nama_paket,
                    metode_pembayaran = NEW.metode_pembayaran,
                    timestamp_pembayaran = NEW.timestamp_pembayaran
                WHERE username = NEW.username
                AND end_date_time >= CURRENT_DATE
                AND start_date_time <= CURRENT_DATE;
                    RETURN NULL; -- Kembalikan NULL karena operasi update telah dilakukan
                END IF;
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
            """
        )

        query(
            f"""
            -- Membuat trigger untuk memicu fungsi beli_paket_langganan saat ada operasi INSERT pada tabel TRANSACTION
            CREATE TRIGGER beli_paket_trigger
            BEFORE INSERT ON TRANSACTION
            FOR EACH ROW
            EXECUTE FUNCTION beli_paket_langganan();
            """
        )

        print("post indent part 2")
        cursor = connection.cursor()

        cursor.execute(
            f"""
            INSERT INTO transaction(username, start_date_time, end_date_time, nama_paket, metode_pembayaran, timestamp_pembayaran)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            [username, start_date_time, end_date_time, nama_paket, metode_pembayaran, timestamp_pembayaran]
        )
        print("success")
        # except Exception as e:
        #     cursor = connection.cursor()
        #     print('failed')
    return redirect("/langganan")