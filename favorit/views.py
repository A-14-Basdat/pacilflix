from django.shortcuts import render

def show_favorit(request):
   return render(request, "favorit.html")