from django.shortcuts import render

def register_user(request):
   return render(request, "register.html")

def login_user(request):
   return render(request, "login.html")

def authentication_user(request):
   return render(request, "authentication.html")
