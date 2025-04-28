from django.shortcuts import render, redirect

from django.http import HttpResponse
from django.db import connection
from django.contrib.auth.decorators import login_required
from django.utils import timezone
from datetime import timedelta
from django.contrib import messages
from django.http import HttpResponseRedirect
from django.urls import reverse
from django.views.decorators.csrf import csrf_protect


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

#@login_required
def delete_tayangan_terunduh(request):
    if request.method == 'POST':
      id_tayangan = request.POST.get('id_tayangan')
      print("id: " ,id_tayangan)
      with connection.cursor() as cursor:
         # Attempt to delete the tayangan; the trigger will prevent it if conditions are not met
         try:
               cursor.execute("DELETE FROM TAYANGAN_TERUNDUH WHERE id_tayangan = %s", [id_tayangan])
               if cursor.rowcount > 0:  # Check if any rows were affected/deleted
                  messages.success(request, 'Tayangan berhasil dihapus.')
               else:
                  messages.error(request, 'Tayangan tidak ditemukan atau tidak dapat dihapus.')
         except Exception as e:
               # The exception message thrown by the trigger will be caught here
               messages.error(request, str(e))

         return HttpResponseRedirect(reverse('unduhan:show_unduhan'))
    else:
        # Redirect atau tampilkan error jika method bukan POST
        return HttpResponseRedirect(reverse('unduhan:show_unduhan'))
