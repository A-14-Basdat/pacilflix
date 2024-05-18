from django.urls import path
from unduhan.views import show_unduhan

app_name = 'unduhan'

urlpatterns = [
    path('', show_unduhan, name='show_unduhan')
]