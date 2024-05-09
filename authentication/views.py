from pyexpat.errors import messages
from django.db import connection
from django.shortcuts import render, redirect
from collections import namedtuple
from django.contrib import messages
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login



def register_user(request):
   return render(request, "register.html")

@csrf_exempt
def login_user(request):
   if request.method == "POST":
      username = request.POST.get("username")
      password = request.POST.get("password")
      cursor = connection.cursor()
      # search if the user is exist in user system
      try:
         cursor.execute(
               f"""
               select * 
               from pengguna
               where username = %s AND password = %s
               """,
               [username, password],
         )
         print('bubu')

      except Exception as e:
         cursor = connection.cursor()
         print('blabla')
      response = cursor.fetchone()
      print(response)
      if response is not None:
         request.session["username"] = response[0]
         request.session["password"] = response[1]
         request.session["is_authenticated"] = True
         print(request, "sfsd")
         print(request.session)
         for key, value in request.session.items():
            print(f"{key}: {value}")  # Print session keys and values for debugging
         # save in session
         request.session.save()
         print('sukses')
         return redirect('/')

      else:
         messages.error(request, "Email atau password yang dimasukkan salah")

   return render(request, "login.html")

def authentication_user(request):
   return render(request, "authentication.html")

# Th3Q!ckF0x