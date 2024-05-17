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

# def register_user(request):
#    form = UserCreationForm()

#    if request.method == "POST" :
#       form = UserCreationForm(request.POST)
#       if form.is_valid():
#          form.save()
#          messages.success(request, 'Your account has been successfully created!')
#          return redirect('authentication:login_user')
#    context = {'form' : form}
#    return render(request, "register.html")

# def register_user(request):
#     form = UserCreationForm()

#     if request.method == "POST":
#         form = UserCreationForm(request.POST)
#         if form.is_valid():
#             try:
#                 form.save()
#                 messages.success(request, 'Your account has been successfully created!')
#                 return redirect('authentication:login_user')
#             except IntegrityError:
#                 messages.error(request, 'Username sudah digunakan. Silakan coba username lain.')

#     context = {'form': form}
#     return render(request, "register.html", context)

def register_user(request):
    if request.method == 'POST':
        username = request.POST.get('username') # PK
        password = request.POST.get('password') # NOT NULL
        negara_asal = request.POST.get('negara_asal') # NOT NULL
        cursor = connection.cursor() 
        query = f"""
        INSERT INTO USER_SYSTEM VALUES ('{username}', '{password}', '{negara_asal});
        
        """   
        print("ini query " + query)
      #   try:
      #       cursor.execute('set search_path to public')
      #       cursor.execute(query)
      #       return redirect('authentication:login')
      #   except InternalError as e: 
      #       messages.info(request, str(e.args))
            
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


# def logout_user(request):
#     request.session['username'] = 'not found'
#     response = HttpResponseRedirect(reverse('authentication:authentication_user'))
#     return response

def logout_user(request):
    del request.session["username"]
    del request.session["password"]
    del request.session["is_authenticated"]
    return redirect("/authentication")