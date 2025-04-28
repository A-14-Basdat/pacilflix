from django.urls import path, register_converter
# from tayangan.views import show_episode, show_film, show_main, show_series
from tayangan.views import show_main, detail_film, detail_series, detail_episode, detail_tayangan, create_review, watch_tayangan, watch_episode, view_trailers, download_film, add_to_favorites
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
    path('series/<uuid:series_id>/<str:episode_judul>/', detail_episode, name='detail_episode'),
    path('create_review/<uuid:id>/', create_review, name='create_review'),
    path('watch/<uuid:id>/', watch_tayangan, name='watch_tayangan'),
    path('watch/<uuid:series_id>/<str:episode_judul>/', watch_episode, name='watch_episode'),
    path('trailers', view_trailers, name='view_trailers'),
    path('download/<uuid:film_id>/', download_film, name='download_film'),
    path('add_to_favorites/<uuid:film_id>/<str:judul>/', add_to_favorites, name='add_to_favorites'),
]

