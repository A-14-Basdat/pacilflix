from django.urls import path
from contributor.views import show_contributor, show_pemain, show_penulis_skenario, show_sutradara

app_name = 'contributor'

urlpatterns = [
    path('', show_contributor, name='show_contributor'),
    path('pemain/', show_pemain, name='show_pemain'),
    path('penulis-skenario/', show_penulis_skenario, name='show_penulis_skenario'),
    path('sutradara/', show_sutradara, name='show_sutradara')
]
