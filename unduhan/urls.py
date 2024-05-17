from django.urls import path
from unduhan.views import show_unduhan, delete_tayangan_terunduh

app_name = 'unduhan'

urlpatterns = [
    path('', show_unduhan, name='show_unduhan'),
    path('delete_tayangan_terunduh', delete_tayangan_terunduh, name='delete_tayangan_terunduh')
]