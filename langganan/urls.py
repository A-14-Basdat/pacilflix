from django.urls import path
from langganan.views import show_langganan, show_beli_basic, show_beli_premium, show_beli_standard

app_name = 'langganan'

urlpatterns = [
    path('', show_langganan, name='show_langganan'),
    path('beli-premium', show_beli_premium, name='show_beli_premium'),
    path('beli-standard', show_beli_standard, name='show_beli_standard'),
    path('beli-basic', show_beli_basic, name='show_beli_basic'),

]