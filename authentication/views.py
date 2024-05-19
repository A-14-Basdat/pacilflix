from pyexpat.errors import messages
from django.db import connection
from django.shortcuts import render, redirect
from collections import namedtuple
from django.contrib import messages
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login
from django.shortcuts import redirect
from django.contrib.auth.forms import UserCreationForm
from django.contrib import messages  
from django.contrib.auth import logout as auth_logout
from django.contrib.auth.forms import UserCreationForm
from django.db import IntegrityError
from django.db import connection, InternalError
from django.http import HttpResponseBadRequest

def register_user(request):
    if request.method == 'POST':
        username = request.POST.get('username')  # PK
        password = request.POST.get('password')  # NOT NULL
        negara_asal = request.POST.get('negara_asal')  # NOT NULL

        cursor = connection.cursor()

        # Check if username already exists
        check_query = f"SELECT COUNT(*) FROM PENGGUNA WHERE username = '{username}';"
        cursor.execute(check_query)
        user_count = cursor.fetchone()[0]

        if user_count > 0:
            messages.error(request, "Username already exists. Please choose a different username.")
            print('udah ada bjir')
            return render(request, 'register.html', {'error_message': 'Username already exists. Please choose a different username.'})
        else:
            insert_query = f"""
            INSERT INTO PENGGUNA (username, password, negara_asal) 
            VALUES ('{username}', '{password}', '{negara_asal}');
            """
            try:
                cursor.execute('set search_path to public')
                cursor.execute(insert_query)
                return redirect('/authentication/login')
            except IntegrityError as e:
                messages.error(request, "An error occurred during registration. Please try again.")
            except Exception as e:
                messages.error(request, str(e))

    return render(request, 'register.html')

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

      except Exception as e:
         cursor = connection.cursor()
      response = cursor.fetchone()
      print(response)
      if response is not None:
         request.session["username"] = response[0]
         request.session["password"] = response[1]
         request.session["is_authenticated"] = True
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

def logout_user(request):
    del request.session["username"]
    del request.session["password"]
    del request.session["is_authenticated"]
    return redirect("/authentication")


