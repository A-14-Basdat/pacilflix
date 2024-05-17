from django.shortcuts import render, redirect

from django.http import HttpResponse
from django.db import connection
from django.contrib.auth.decorators import login_required
from django.utils import timezone
from datetime import timedelta
from django.contrib import messages


#@login_required  # Ensure that only logged-in users can access this view
def show_unduhan(request):
    username = request.session.get("username") # Get the username from the logged-in user

    with connection.cursor() as cursor:
        # SQL query to join tables and fetch required information
        cursor.execute("""
            SELECT tt.id_tayangan, t.judul, tt.timestamp
            FROM TAYANGAN_TERUNDUH tt
            JOIN TAYANGAN t ON tt.id_tayangan = t.id
            WHERE tt.username = %s
        """, [username])
        downloads = cursor.fetchall()
    
    print(downloads[1:3])
    return render(request, 'unduhan.html', {'downloads': downloads})

@login_required
def delete_tayangan_terunduh(request, id_tayangan):
    with connection.cursor() as cursor:
        # Check if the tayangan can be deleted
        cursor.execute("SELECT timestamp FROM TAYANGAN_TERUNDUH WHERE id_tayangan = %s", [id_tayangan])
        result = cursor.fetchone()
        
        if result:
            timestamp = result[0]
            now = timezone.now()
            if now - timestamp > timedelta(days=1):
                cursor.execute("DELETE FROM TAYANGAN_TERUNDUH WHERE id_tayangan = %s", [id_tayangan])
                messages.success(request, 'Tayangan berhasil dihapus.')
            else:
                messages.error(request, 'Tayangan tidak dapat dihapus karena belum terunduh selama lebih dari 1 hari.')
        else:
            messages.error(request, 'Tayangan tidak ditemukan.')
    
    return redirect('tayangan_details')
