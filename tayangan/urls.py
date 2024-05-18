from django.urls import path, register_converter
# from tayangan.views import show_episode, show_film, show_main, show_series
from tayangan.views import show_main, detail_film, detail_series, detail_episode, detail_tayangan
import uuid

# Custom UUID converter
class UUIDConverter:
    regex = '[0-9a-f-]{36}'

    def to_python(self, value):
        return uuid.UUID(value)

    def to_url(self, value):
        return str(value)

register_converter(UUIDConverter, 'uuid')

app_name = 'tayangan'

urlpatterns = [
    path('', show_main, name='show_main'),
    path('film/<uuid:id>/', detail_film, name='detail_film'),
    path('series/<uuid:id>/', detail_series, name='detail_series'),
    path('tayangan/<uuid:id>/', detail_tayangan, name='detail_tayangan'),
    # path('film/', show_film, name='show_film'),
    # path('series/', show_series, name='show_series'),
    # path('series/episode/', show_episode, name='show_episode'),
    path('series/<uuid:series_id>/<str:episode_judul>/', detail_episode, name='detail_episode'),
]

