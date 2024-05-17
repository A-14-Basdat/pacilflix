from django.urls import path
from favorit.views import show_favorit, hapus_favorit

app_name = 'favorit'

urlpatterns = [
    path('', show_favorit, name='show_favorit'),
    path('hapus-favorit/', hapus_favorit, name='hapus_favorit'),
]

