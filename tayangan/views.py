import uuid
from django.db import connection
from django.http import HttpResponse
from django.shortcuts import render, redirect
from collections import namedtuple

def map_cursor(cursor):
    description = cursor.description
    query_result = namedtuple("Data", [col[0] for col in description])
    return [query_result(*row) for row in cursor.fetchall()]

def query(query_str: str, params=None):
    result = []
    with connection.cursor() as cursor:
        try:
            cursor.execute(query_str, params)
            if query_str.strip().lower().startswith("select"):
                result = map_cursor(cursor)
            else:
                result = cursor.rowcount
        except Exception as e:
            result = e
    return result

def show_main(request):
    search_query = request.GET.get('q', '')

    search_results = []
    no_results_message = ""

    if search_query:
        # If there's a search query, perform search
        search_results = query(
            """
            SELECT T.id, T.judul, T.sinopsis_trailer, T.url_video_trailer, T.release_date_trailer
            FROM TAYANGAN T
            WHERE T.judul ILIKE %s
            """, [f"%{search_query}%"]
        )
        if not search_results:
            no_results_message = "Film atau series belum tersedia di Pacilflix."


    # Fetch film data
    films = query(
        """
        SELECT T.id, T.judul, T.sinopsis, T.asal_negara, T.sinopsis_trailer, 
               T.url_video_trailer, T.release_date_trailer, 
               F.url_video_film, F.release_date_film, F.durasi_film
        FROM TAYANGAN T
        JOIN FILM F ON T.id = F.id_tayangan;
        """
    )

    # Fetch series data
    series = query(
        """
        SELECT T.id, T.judul, T.sinopsis, T.asal_negara, T.sinopsis_trailer, 
               T.url_video_trailer, T.release_date_trailer
        FROM TAYANGAN T
        JOIN SERIES S ON T.id = S.id_tayangan;
        """
    )

    # Fetch episode data
    episodes = query(
        """
        SELECT E.id_series, E.sub_judul, E.sinopsis, E.durasi, E.url_video, 
               E.release_date, T.judul as series_judul
        FROM EPISODE E
        JOIN SERIES S ON E.id_series = S.id_tayangan
        JOIN TAYANGAN T ON S.id_tayangan = T.id;
        """
    )

    # Ambil 10 tayangan teratas berdasarkan jumlah viewer dalam 7 hari terakhir
    top_10 = query(
        """
        SELECT T.id, T.judul, T.sinopsis_trailer, T.url_video_trailer, T.release_date_trailer, COUNT(R.username) as total_views
        FROM RIWAYAT_NONTON R
        JOIN TAYANGAN T ON R.id_tayangan = T.id
        LEFT JOIN FILM F ON T.id = F.id_tayangan
        LEFT JOIN EPISODE E ON T.id = E.id_series
        WHERE EXTRACT(EPOCH FROM (R.end_date_time - R.start_date_time)) / 60 >= 
              CASE
                  WHEN F.id_tayangan IS NOT NULL THEN 0.7 * F.durasi_film
                  WHEN E.id_series IS NOT NULL THEN 0.7 * E.durasi
              END
        GROUP BY T.id, T.judul, T.sinopsis_trailer, T.url_video_trailer, T.release_date_trailer
        ORDER BY total_views DESC
        LIMIT 10;
        """
    )

    if isinstance(top_10, Exception):
        top_10 = []


    context = {
        "films": films,
        "series": series,
        "episodes": episodes,
        "search_results": search_results,  # Ensure this is passed to the context
        "no_results_message": no_results_message,  # Ensure this is passed to the context
        "top_10": list(enumerate(top_10)), 
    }
    return render(request, "tayangan.html", context)

def get_tayangan_type(tayangan_id):
 
    # Query untuk memeriksa apakah tayangan adalah film
    is_film = query("SELECT id_tayangan FROM FILM WHERE id_tayangan = %s", [str(tayangan_id)])
    if is_film:
        return 'film'

    # Query untuk memeriksa apakah tayangan adalah series
    is_series = query("SELECT id_tayangan FROM SERIES WHERE id_tayangan = %s", [str(tayangan_id)])
    if is_series:
        return 'series'

    # Jika tayangan bukan film maupun series
    return None


def detail_film(request, id):
    username = request.session.get("username")
    id = str(id)  # Convert UUID to string for the query
    film = query("""
        SELECT T.id, T.judul, T.sinopsis, F.durasi_film, F.release_date_film, F.url_video_film, T.asal_negara
        FROM TAYANGAN T
        JOIN FILM F ON T.id = F.id_tayangan
        WHERE id = %s
    """, [str(id)])
    #film = cursor.fetchone()

    genres = query("""
        SELECT GT.genre
        FROM GENRE_TAYANGAN GT
        WHERE GT.id_tayangan = %s
    """, [str(id)])
    #genres = cursor.fetchall()
    genre_list = [genre[0] for genre in genres]
    #if len(genre_list) > 1:
    if genre_list:
        genre_list = genre_list[0].split(', ')
    else:
        genre_list = [] 

    actors = query("""
        SELECT C.nama FROM CONTRIBUTORS C
        JOIN MEMAINKAN_TAYANGAN MT ON MT.id_pemain = C.id 
        JOIN TAYANGAN T ON T.id = MT.id_tayangan
        WHERE T.id = %s
    """, [str(id)])
    #actors = cursor.fetchall()
    actor_list = [actor[0] for actor in actors]

    writers = query("""
        SELECT C.nama FROM CONTRIBUTORS C
        JOIN MENULIS_SKENARIO_TAYANGAN MST ON MST.id_penulis_skenario = C.id 
        JOIN TAYANGAN T ON T.id = MST.id_tayangan
        WHERE T.id = %s
    """, [str(id)])
    #writers = cursor.fetchall()
    writer_list = [writer[0] for writer in writers]

    director = query("""
        SELECT S.id, C.nama
        FROM SUTRADARA S
        JOIN CONTRIBUTORS C ON C.id = S.id
        JOIN TAYANGAN T ON T.id_sutradara = S.id WHERE T.id = %s
    """, [str(id)])
    #director = cursor.fetchone()

    # Fetch reviews for the selected film
    reviews = query("""
        SELECT username, timestamp, rating, deskripsi
        FROM ULASAN
        WHERE id_tayangan = %s
    """, [str(id)])

    total_ratings = sum(review.rating for review in reviews)
    average_rating = total_ratings / len(reviews) if reviews else 0

    # Count the total views of the selected film
    total_views = query("""
        SELECT COUNT(*)
        FROM RIWAYAT_NONTON
        WHERE id_tayangan = %s
        AND EXTRACT(EPOCH FROM (end_date_time - start_date_time)) / 60 >= 0.7 * (
            SELECT durasi_film FROM FILM WHERE id_tayangan = %s
        )
    """, [str(id), str(id)])
    total_views = total_views[0][0] if total_views else 0

    print(film, genre_list, actor_list, writer_list, director, reviews, total_views)


    return render(request, 'film.html', {
        'film': film,
        'genre_list': genre_list,
        'actor_list': actor_list,
        'writer_list': writer_list,
        'director': director,
        'reviews' : reviews,
        'average_rating': average_rating,
        'total_views' : total_views
        })

def detail_series(request, id):
    username = request.session.get("username")
    id = str(id)  # Convert UUID to string for the query
    series = query("""
        SELECT T.id, T.judul, T.sinopsis, T.asal_negara, 
               array_agg(E.id_series) as episode_ids,
               array_agg(E.sub_judul) as episode_titles
        FROM TAYANGAN T
        JOIN SERIES S ON T.id = S.id_tayangan
        JOIN EPISODE E ON S.id_tayangan = E.id_series
        WHERE T.id = %s
        GROUP BY T.id, T.judul, T.sinopsis, T.asal_negara
    """, [str(id)])

    #film = cursor.fetchone()

    genres = query("""
        SELECT GT.genre
        FROM GENRE_TAYANGAN GT
        WHERE GT.id_tayangan = %s
    """, [str(id)])
    #genres = cursor.fetchall()
    genre_list = [genre[0] for genre in genres]
    if genre_list:
        genre_list = genre_list[0].split(', ')
    else:
        genre_list = [] 

    actors = query("""
        SELECT C.nama FROM CONTRIBUTORS C
        JOIN MEMAINKAN_TAYANGAN MT ON MT.id_pemain = C.id 
        JOIN TAYANGAN T ON T.id = MT.id_tayangan
        WHERE T.id = %s
    """, [str(id)])
    #actors = cursor.fetchall()
    actor_list = [actor[0] for actor in actors]

    writers = query("""
        SELECT C.nama FROM CONTRIBUTORS C
        JOIN MENULIS_SKENARIO_TAYANGAN MST ON MST.id_penulis_skenario = C.id 
        JOIN TAYANGAN T ON T.id = MST.id_tayangan
        WHERE T.id = %s
    """, [str(id)])
    #writers = cursor.fetchall()
    writer_list = [writer[0] for writer in writers]

    director = query("""
        SELECT S.id, C.nama
        FROM SUTRADARA S
        JOIN CONTRIBUTORS C ON C.id = S.id
        JOIN TAYANGAN T ON T.id_sutradara = S.id WHERE T.id = %s
    """, [str(id)])
    #director = cursor.fetchone()

    # Fetch reviews for the selected film
    reviews = query("""
        SELECT username, timestamp, rating, deskripsi
        FROM ULASAN
        WHERE id_tayangan = %s
    """, [str(id)])

    total_ratings = sum(review.rating for review in reviews)
    average_rating = total_ratings / len(reviews) if reviews else 0

    # Count the total views of the selected series based on episode duration
    total_views = query("""
        SELECT COUNT(*)
        FROM RIWAYAT_NONTON RN
        JOIN EPISODE E ON RN.id_tayangan = E.id_series
        WHERE E.id_series = %s
        AND EXTRACT(EPOCH FROM (RN.end_date_time - RN.start_date_time)) / 60 >= 0.7 * E.durasi
    """, [str(id)])
    total_views = total_views[0][0] if total_views else 0

    print(series, genre_list, actor_list, writer_list, director, reviews, total_views)

    return render(request, 'series.html', {
        'series': series,
        'genre_list': genre_list,
        'actor_list': actor_list,
        'writer_list': writer_list,
        'director': director,
        'reviews' : reviews,
        'average_rating': average_rating,
        'total_views' : total_views
        })

def detail_episode(request, series_id, episode_judul):
    # Ambil data episode dari basis data berdasarkan episode_id
    episode = query("""
        SELECT E.sub_judul, E.sinopsis, E.durasi, E.url_video, E.release_date, T.judul as series_judul
        FROM EPISODE E
        JOIN TAYANGAN T ON E.id_series = T.id
        WHERE E.id_series = %s AND E.sub_judul = %s
    """, [str(series_id), str(episode_judul)])

    # Fetch other episodes for the same series
    other_episodes = query("""
        SELECT E.sub_judul, E.sinopsis, E.durasi, E.url_video, E.release_date, T.judul as series_judul
        FROM EPISODE E
        JOIN TAYANGAN T ON E.id_series = T.id
        WHERE E.id_series = %s AND E.sub_judul != %s
    """, [str(series_id), str(episode_judul)])

    if episode:
        series_judul = episode[0].series_judul
    else:
        series_judul = None  # Set to None if episode is not found
    
    print(episode, other_episodes, series_judul)

    # Render halaman detail episode dengan data episode yang sudah diperoleh
    return render(request, 'episode.html', {
        'episode': episode, 
        'series_judul': series_judul,
        'series_id': series_id, 
        'other_episodes': other_episodes
        })

def detail_tayangan(request, id):
    tayangan_type = get_tayangan_type(id)  # Anda perlu mengganti ini dengan cara Anda untuk mendapatkan tipe tayangan

    if tayangan_type == 'film':
        id = str(id)  # Convert UUID to string for the query
        film = query("""
            SELECT T.id, T.judul, T.sinopsis, F.durasi_film, F.release_date_film, F.url_video_film, T.asal_negara
            FROM TAYANGAN T
            JOIN FILM F ON T.id = F.id_tayangan
            WHERE id = %s
        """, [str(id)])
        #film = cursor.fetchone()

        genres = query("""
            SELECT GT.genre
            FROM GENRE_TAYANGAN GT
            WHERE GT.id_tayangan = %s
        """, [str(id)])
        #genres = cursor.fetchall()
        genre_list = [genre[0] for genre in genres]
        #if len(genre_list) > 1:
        if genre_list:
            genre_list = genre_list[0].split(', ')
        else:
            genre_list = [] 

        actors = query("""
            SELECT C.nama FROM CONTRIBUTORS C
            JOIN MEMAINKAN_TAYANGAN MT ON MT.id_pemain = C.id 
            JOIN TAYANGAN T ON T.id = MT.id_tayangan
            WHERE T.id = %s
        """, [str(id)])
        #actors = cursor.fetchall()
        actor_list = [actor[0] for actor in actors]

        writers = query("""
            SELECT C.nama FROM CONTRIBUTORS C
            JOIN MENULIS_SKENARIO_TAYANGAN MST ON MST.id_penulis_skenario = C.id 
            JOIN TAYANGAN T ON T.id = MST.id_tayangan
            WHERE T.id = %s
        """, [str(id)])
        #writers = cursor.fetchall()
        writer_list = [writer[0] for writer in writers]

        director = query("""
            SELECT S.id, C.nama
            FROM SUTRADARA S
            JOIN CONTRIBUTORS C ON C.id = S.id
            JOIN TAYANGAN T ON T.id_sutradara = S.id WHERE T.id = %s
        """, [str(id)])
        #director = cursor.fetchone()

        # Fetch reviews for the selected film
        reviews = query("""
            SELECT username, timestamp, rating, deskripsi
            FROM ULASAN
            WHERE id_tayangan = %s
        """, [str(id)])

        total_ratings = sum(review.rating for review in reviews)
        average_rating = total_ratings / len(reviews) if reviews else 0

        # Count the total views of the selected film
        total_views = query("""
            SELECT COUNT(*)
            FROM RIWAYAT_NONTON
            WHERE id_tayangan = %s
            AND EXTRACT(EPOCH FROM (end_date_time - start_date_time)) / 60 >= 0.7 * (
                SELECT durasi_film FROM FILM WHERE id_tayangan = %s
            )
        """, [str(id), str(id)])
        total_views = total_views[0][0] if total_views else 0

        print(film, genre_list, actor_list, writer_list, director, reviews, total_views)

        return render(request, 'film.html', {
            'film': film,
            'genre_list': genre_list,
            'actor_list': actor_list,
            'writer_list': writer_list,
            'director': director,
            'reviews' : reviews,
            'average_rating': average_rating,
            'total_views' : total_views
            })
    else:
        id = str(id)  # Convert UUID to string for the query
        series = query("""
            SELECT T.id, T.judul, T.sinopsis, T.asal_negara, 
                array_agg(E.id_series) as episode_ids,
                array_agg(E.sub_judul) as episode_titles
            FROM TAYANGAN T
            JOIN SERIES S ON T.id = S.id_tayangan
            JOIN EPISODE E ON S.id_tayangan = E.id_series
            WHERE T.id = %s
            GROUP BY T.id, T.judul, T.sinopsis, T.asal_negara
        """, [str(id)])

        #film = cursor.fetchone()

        genres = query("""
            SELECT GT.genre
            FROM GENRE_TAYANGAN GT
            WHERE GT.id_tayangan = %s
        """, [str(id)])
        #genres = cursor.fetchall()
        genre_list = [genre[0] for genre in genres]
        if genre_list:
            genre_list = genre_list[0].split(', ')
        else:
            genre_list = [] 

        actors = query("""
            SELECT C.nama FROM CONTRIBUTORS C
            JOIN MEMAINKAN_TAYANGAN MT ON MT.id_pemain = C.id 
            JOIN TAYANGAN T ON T.id = MT.id_tayangan
            WHERE T.id = %s
        """, [str(id)])
        #actors = cursor.fetchall()
        actor_list = [actor[0] for actor in actors]

        writers = query("""
            SELECT C.nama FROM CONTRIBUTORS C
            JOIN MENULIS_SKENARIO_TAYANGAN MST ON MST.id_penulis_skenario = C.id 
            JOIN TAYANGAN T ON T.id = MST.id_tayangan
            WHERE T.id = %s
        """, [str(id)])
        #writers = cursor.fetchall()
        writer_list = [writer[0] for writer in writers]

        director = query("""
            SELECT S.id, C.nama
            FROM SUTRADARA S
            JOIN CONTRIBUTORS C ON C.id = S.id
            JOIN TAYANGAN T ON T.id_sutradara = S.id WHERE T.id = %s
        """, [str(id)])
        #director = cursor.fetchone()

        # Fetch reviews for the selected film
        reviews = query("""
            SELECT username, timestamp, rating, deskripsi
            FROM ULASAN
            WHERE id_tayangan = %s
        """, [str(id)])

        total_ratings = sum(review.rating for review in reviews)
        average_rating = total_ratings / len(reviews) if reviews else 0

        # Count the total views of the selected series based on episode duration
        total_views = query("""
            SELECT COUNT(*)
            FROM RIWAYAT_NONTON RN
            JOIN EPISODE E ON RN.id_tayangan = E.id_series
            WHERE E.id_series = %s
            AND EXTRACT(EPOCH FROM (RN.end_date_time - RN.start_date_time)) / 60 >= 0.7 * E.durasi
        """, [str(id)])
        total_views = total_views[0][0] if total_views else 0

        print(series, genre_list, actor_list, writer_list, director, reviews, total_views)
        return render(request, 'series.html', {
            'series': series,
            'genre_list': genre_list,
            'actor_list': actor_list,
            'writer_list': writer_list,
            'director': director,
            'reviews' : reviews,
            'average_rating': average_rating,
            'total_views' : total_views
            })
  
