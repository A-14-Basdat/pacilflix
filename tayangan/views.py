from datetime import datetime
from django.contrib import messages
import uuid
from django.db import InternalError, connection
from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import render, redirect
from collections import namedtuple
from urllib.parse import quote


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

def view_trailers(request):
    search_query = request.GET.get('q', '')

    search_results = []
    no_results_message = ""

    if search_query:
        search_results = query(
            """
            SELECT T.id, T.judul, T.sinopsis_trailer, T.url_video_trailer, T.release_date_trailer
            FROM TAYANGAN T
            WHERE T.judul ILIKE %s
            """, [f"%{search_query}%"]
        )
        if not search_results:
            no_results_message = "Film atau series belum tersedia di Pacilflix."


    films = query(
        """
        SELECT T.id, T.judul, T.sinopsis, T.asal_negara, T.sinopsis_trailer, 
               T.url_video_trailer, T.release_date_trailer, 
               F.url_video_film, F.release_date_film, F.durasi_film
        FROM TAYANGAN T
        JOIN FILM F ON T.id = F.id_tayangan;
        """
    )

    series = query(
        """
        SELECT T.id, T.judul, T.sinopsis, T.asal_negara, T.sinopsis_trailer, 
               T.url_video_trailer, T.release_date_trailer
        FROM TAYANGAN T
        JOIN SERIES S ON T.id = S.id_tayangan;
        """
    )

    episodes = query(
        """
        SELECT E.id_series, E.sub_judul, E.sinopsis, E.durasi, E.url_video, 
               E.release_date, T.judul as series_judul
        FROM EPISODE E
        JOIN SERIES S ON E.id_series = S.id_tayangan
        JOIN TAYANGAN T ON S.id_tayangan = T.id;
        """
    )

    top_10 = query(
        """
        SELECT T.id, T.judul, T.sinopsis_trailer, T.url_video_trailer, T.release_date_trailer, COUNT(R.username) as total_views
        FROM RIWAYAT_NONTON R
        JOIN TAYANGAN T ON R.id_tayangan = T.id
        LEFT JOIN FILM F ON T.id = F.id_tayangan
        LEFT JOIN EPISODE E ON T.id = E.id_series
        WHERE R.end_date_time >= NOW() - INTERVAL '7 days'
        AND EXTRACT(EPOCH FROM (R.end_date_time - R.start_date_time)) / 60 >= 
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
        "search_results": search_results,  
        "no_results_message": no_results_message, 
        "top_10": list(enumerate(top_10)), 
    }
    # return render(request, "tayangan.html", context)
    return render(request, 'trailer.html', context)


def show_main(request):
    if "username" in request.session:
        search_query = request.GET.get('q', '')

        search_results = []
        no_results_message = ""

        if search_query:
            search_results = query(
                """
                SELECT T.id, T.judul, T.sinopsis_trailer, T.url_video_trailer, T.release_date_trailer
                FROM TAYANGAN T
                WHERE T.judul ILIKE %s
                """, [f"%{search_query}%"]
            )
            if not search_results:
                no_results_message = "Film atau series belum tersedia di Pacilflix."


        films = query(
            """
            SELECT T.id, T.judul, T.sinopsis, T.asal_negara, T.sinopsis_trailer, 
                T.url_video_trailer, T.release_date_trailer, 
                F.url_video_film, F.release_date_film, F.durasi_film
            FROM TAYANGAN T
            JOIN FILM F ON T.id = F.id_tayangan;
            """
        )

        series = query(
            """
            SELECT T.id, T.judul, T.sinopsis, T.asal_negara, T.sinopsis_trailer, 
                T.url_video_trailer, T.release_date_trailer
            FROM TAYANGAN T
            JOIN SERIES S ON T.id = S.id_tayangan;
            """
        )

        episodes = query(
            """
            SELECT E.id_series, E.sub_judul, E.sinopsis, E.durasi, E.url_video, 
                E.release_date, T.judul as series_judul
            FROM EPISODE E
            JOIN SERIES S ON E.id_series = S.id_tayangan
            JOIN TAYANGAN T ON S.id_tayangan = T.id;
            """
        )

        top_10 = query(
            """
            SELECT T.id, T.judul, T.sinopsis_trailer, T.url_video_trailer, T.release_date_trailer, COUNT(R.username) as total_views
            FROM RIWAYAT_NONTON R
            JOIN TAYANGAN T ON R.id_tayangan = T.id
            LEFT JOIN FILM F ON T.id = F.id_tayangan
            LEFT JOIN EPISODE E ON T.id = E.id_series
            WHERE R.end_date_time >= NOW() - INTERVAL '7 days'
            AND EXTRACT(EPOCH FROM (R.end_date_time - R.start_date_time)) / 60 >= 
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
            "search_results": search_results, 
            "no_results_message": no_results_message,  
            "top_10": list(enumerate(top_10)), 
        }
        return render(request, "tayangan.html", context)
    else:
        return redirect('/authentication')

def get_tayangan_type(tayangan_id):
 
    is_film = query("SELECT id_tayangan FROM FILM WHERE id_tayangan = %s", [str(tayangan_id)])
    if is_film:
        return 'film'

    is_series = query("SELECT id_tayangan FROM SERIES WHERE id_tayangan = %s", [str(tayangan_id)])
    if is_series:
        return 'series'

    return None


def detail_film(request, id):
    username = request.session.get("username")
    id = str(id)  
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

    reviews = query("""
        SELECT username, timestamp, rating, deskripsi
        FROM ULASAN
        WHERE id_tayangan = %s
    """, [str(id)])

    total_ratings = sum(review.rating for review in reviews)
    average_rating = total_ratings / len(reviews) if reviews else 0

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
    id = str(id)  
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
    episode = query("""
        SELECT E.sub_judul, E.sinopsis, E.durasi, E.url_video, E.release_date, T.judul as series_judul
        FROM EPISODE E
        JOIN TAYANGAN T ON E.id_series = T.id
        WHERE E.id_series = %s AND E.sub_judul = %s
    """, [str(series_id), str(episode_judul)])

    other_episodes = query("""
        SELECT E.sub_judul, E.sinopsis, E.durasi, E.url_video, E.release_date, T.judul as series_judul
        FROM EPISODE E
        JOIN TAYANGAN T ON E.id_series = T.id
        WHERE E.id_series = %s AND E.sub_judul != %s
    """, [str(series_id), str(episode_judul)])

    if episode:
        series_judul = episode[0].series_judul
    else:
        series_judul = None  
    
    print(episode, other_episodes, series_judul)

    return render(request, 'episode.html', {
        'episode': episode, 
        'series_judul': series_judul,
        'series_id': series_id, 
        'other_episodes': other_episodes
        })

def detail_tayangan(request, id):
    id = str(id)  
    tayangan_type = get_tayangan_type(id)
    
    if tayangan_type == 'film':
        return detail_film(request, id)
    elif tayangan_type == 'series':
        return detail_series(request, id)
    else:
        return HttpResponse("Tayangan not found", status=404)
    
def create_review(request, id):
    
    if request.method == 'POST':
        username = request.session.get("username")
        rating = request.POST.get('rating')
        deskripsi = request.POST.get('deskripsi')
        timestamp = datetime.now()

        if  not rating or not deskripsi:
            messages.error(request, 'All fields are required.')
            print("error, gagal")
            return HttpResponseRedirect(f'/tayangan/{id}')
        
        try:
            with connection.cursor() as cursor:
                
                cursor.execute("""
                    INSERT INTO ULASAN (username, timestamp, rating, deskripsi, id_tayangan)
                    VALUES (%s, %s, %s, %s, %s)
                """, [username, timestamp, rating, deskripsi, id])
                print("horee bisa")
                messages.add_message(request, messages.SUCCESS, 'Ulasan anda berhasil ditambahkan!', extra_tags='ulasan')

        except InternalError as e:
            print("error lagi woi")
            
            messages.add_message(request, messages.ERROR, f"Anda sudah memberikan ulasan untuk tayangan ini!", extra_tags='ulasan')
        
        tayangan_type = get_tayangan_type(id)
        if tayangan_type == 'film':
            return HttpResponseRedirect(f'/tayangan/{id}')
        elif tayangan_type == 'series':
            return HttpResponseRedirect(f'/tayangan/{id}')
        else:
            return HttpResponse("Tayangan not found", status=404)

    return HttpResponseRedirect(f'/tayangan')

def watch_tayangan(request, id):
    if request.method == "POST":
        username = request.session.get("username")
        progress = int(request.POST['progress'])
        durasi = int(request.POST['durasi'])
        progress = int((progress/100) * durasi)

        cursor = connection.cursor()
        try:
            cursor.execute(f"""
                INSERT INTO RIWAYAT_NONTON VALUES ('{id}', '{username}', NOW(), NOW() + {progress} * INTERVAL '1 minute');
            """)
            messages.add_message(request, messages.SUCCESS, 'Terimakasih sudah menonton film ini!', extra_tags='tonton')
        except InternalError as e:
            messages.add_message(request, messages.ERROR, 'Maaf, tayangan tidak bisa ditonton.', extra_tags='tonton')
        
        tayangan_type = get_tayangan_type(id)
        if tayangan_type == 'series':
            subjudul = request.POST['subjudul']
            encoded = quote(subjudul)
            return HttpResponseRedirect(f'/tayangan/{id}/{encoded}')
        elif tayangan_type == 'film':
            return HttpResponseRedirect(f'/tayangan/{id}')
        else:
            return HttpResponseRedirect('/tayangan')

    return HttpResponseRedirect('/tayangan')  

def watch_episode(request, series_id, episode_judul):
    # encoded_judul = quote(episode_judul)
    if request.method == "POST":
        username = request.session.get("username")
        progress = request.POST.get('progress', '')  
        durasi = request.POST.get('durasi', '')      
        print(f"durasinya {durasi} menit")
        if progress and durasi:
            try:
                progress = int(progress)
                durasi = int(durasi)
                progress = int((progress/100) * durasi)

                cursor = connection.cursor()
                cursor.execute(f"""
                    INSERT INTO RIWAYAT_NONTON VALUES ('{series_id}', '{username}', NOW(), NOW() + {progress} * INTERVAL '1 minute');
                """)

                print(f"progressnya {progress} menit")
                messages.success(request, 'Terimakasih sudah menonton episode ini!')
            except ValueError:
                messages.error(request, 'Progress dan durasi harus berupa bilangan bulat positif.')
            except Exception as e:
                messages.error(request, 'Maaf, episode tidak bisa ditonton.')

            return HttpResponseRedirect(f'/series/{series_id}/{episode_judul}/')
        else:
            messages.error(request, 'Progress dan durasi harus diisi.')
            return HttpResponseRedirect(request.path)

    return HttpResponseRedirect(f'/series/{series_id}/{episode_judul}/')

def download_film(request, film_id):
    if request.method == "POST":
        username = username = request.session.get("username")
        timestamp = datetime.now()

        with connection.cursor() as cursor:
            cursor.execute(
                "INSERT INTO tayangan_terunduh (id_tayangan, username, timestamp) VALUES (%s, %s, %s)",
                [film_id, username, timestamp]
            )

        return redirect('unduhan:show_unduhan')
    else:
        return HttpResponse("Invalid request", status=400)

def add_to_favorites(request, film_id, judul):
    if request.method == "POST":
        username =  request.session.get("username") # Use Django's authentication system

        # Current timestamp
        current_timestamp = datetime.now()

        # Ensure there is a record in DAFTAR_FAVORIT for the film and user
        with connection.cursor() as cursor:
            # This inserts a new favorite list entry if not already present
            cursor.execute("""
                INSERT INTO daftar_favorit (timestamp, username, judul)
                VALUES (%s, %s, %s)
            """, [current_timestamp, username, judul])

        # Insert the favorite film entry linking the film to the user
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO tayangan_memiliki_daftar_favorit (id_tayangan, timestamp, username)
                VALUES (%s, %s, %s)
            """, [film_id, current_timestamp, username])

        return redirect('favorit:show_favorit')  # Redirect to a confirmation page, etc.
    else:
        return HttpResponse("Invalid request", status=400)