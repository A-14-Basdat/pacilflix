from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.db import connection
from django.http import HttpResponseRedirect
from django.urls import reverse
from django.views.decorators.csrf import csrf_protect

#//@login_required
def show_favorit(request):
    username  = request.session.get("username")  # Mengambil username dari user yang login
    print(username);
    with connection.cursor() as cursor:
        cursor.execute("SELECT judul, timestamp FROM DAFTAR_FAVORIT WHERE username = %s", [username])
        rows = cursor.fetchall()
    
    # Mengirim data ke template
    print(rows)
    return render(request, 'favorit.html', {'favorits': rows})

def hapus_favorit(request):
    if request.method == 'POST':
        judul = request.POST.get('judul')
        print(judul+"heheh")
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM DAFTAR_FAVORIT WHERE judul = %s", [judul])
        return HttpResponseRedirect(reverse('favorit:show_favorit'))
    else:
        # Redirect atau tampilkan error jika method bukan POST
        return HttpResponseRedirect(reverse('favorit:show_favorit'))
