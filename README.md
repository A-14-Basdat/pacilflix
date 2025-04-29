
<p align="center">
<img src="staticfiles/image/Screen%20Shot%202024-04-27%20at%2021.40.06%201-Photoroom.0a0c52b78d0c.png" width="300" />
</p>

# Pacilflix

Movie catalog web application group project applying Django and PostgreSQL queries as the backend.
## Description

Movie catalog web application which provides a multitude of features such as viewing movies, adding to favorites, managing packages, and many more. Specifically developed for a database class, this project was designed to emphasize our understanding of raw PostgreSQL queries; hence, the core application's database schema (including tables like pengguna, film, paket, contributors, etc.) was managed directly using raw SQL, without defining corresponding Django models or utilizing Django's ORM for these specific entities.

## Built With

[![Python][Python]][Python-url] [![Django][Django]][Django-url] [![PostgreSQL][PostgreSQL]][PostgreSQL-url] 

## Features

* Movie Progress Tracking: View and update your watch history.
* Review System: Add and read user reviews for movies and series.
* Package Management: Manage your Pacilflix subscription.
* Favorites List: Create and view your favorite movies and series.
* Contributor Database: Browse directors, actors, and screenwriters.


## Getting Started


### Dependencies

* [Python][Python-url] (latest)
* [Django][Django-url] (latest)
* [PostgreSQL][PostgreSQL-url] (latest)

### Installing

1. Clone the repository
```
git clone https://github.com/A-14-Basdat/pacilflix.git
cd pacilflix
```

2. Install dependencies:
```
pip install -r requirements.txt
```
### Database setup
Pacilflix's core database schema (including tables like pengguna, film, paket, contributors, etc.) is set up and managed directly using raw PostgreSQL SQL, separate from Django's built-in applications which utilize its migration system. To get the database ready, follow these steps

#### Prerequisites

- PostgreSQL installed on your system
- PostgreSQL credentials with permission to create databases

#### Setup Instructions

1. Create the database:
```bash
psql -h 127.0.0.1 -p 5432 -U your_postgres_username -c "CREATE DATABASE pacilflix WITH ENCODING='UTF8';"
```

2. Run the SQL script to populate the database
```bash
psql -h 127.0.0.1 -p 5432 -U your_postgres_username -d pacilflix -f TK3_SQL_A14.sql
```

3. Apply Django Migrations (for built-in apps):
```
python manage.py migrate
```
or 
```
python3 manage.py migrate
```


### Executing program

```
python manage.py runserver
```
or 
```
python3 manage.py runserver
```




<!-- MARKDOWN LINKS & IMAGES -->
[Python]: https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white
[Python-url]: https://www.python.org/
[Django]: https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white
[Django-url]: https://www.djangoproject.com/
[PostgreSQL]: https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white
[PostgreSQL-url]: https://www.postgresql.org/

