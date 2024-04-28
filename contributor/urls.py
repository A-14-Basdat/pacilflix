from django.urls import path
from contributor.views import show_contributor

app_name = 'contributor'

urlpatterns = [
    path('', show_contributor, name='show_contributor')
]

