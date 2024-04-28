from django.urls import path
from favorit.views import show_favorit

app_name = 'favorit'

urlpatterns = [
    path('', show_favorit, name='show_favorit'),
]

