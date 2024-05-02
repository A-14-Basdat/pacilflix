from django.shortcuts import render

def show_contributor(request):
   return render(request, "contributor.html")

