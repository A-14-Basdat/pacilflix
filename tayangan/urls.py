from django.urls import path
from tayangan.views import show_main

app_name = 'tayangan'

urlpatterns = [
    path('', show_main, name='show_main'),
]

