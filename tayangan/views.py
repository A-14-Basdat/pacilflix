from django.shortcuts import render

def show_main(request):
   return render(request, "tayangan.html")

def show_film(request):
    return render(request, "film.html")

def show_series(request):
    return render(request, "series.html")
