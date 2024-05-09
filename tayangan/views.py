from django.shortcuts import render
from django.contrib.auth.decorators import login_required

def show_main(request):
   return render(request, "tayangan.html")

def show_film(request):
    return render(request, "film.html")

def show_series(request):
    return render(request, "series.html")

def show_episode(request):
    return render(request, "episode.html")
