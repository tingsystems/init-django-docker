# Presentacion del curso
[Presentacion](https://docs.google.com/presentation/d/1UMVlVxcdGMVrvmDMt-5Mi1nsH81xQn0TW7TJI5lDRyI/edit?usp=sharing)

# Inicio rapido: Docker, docker compose y Django

Esta guia nos muestra como iniciar un proyecto nuevo de Django apoyandonos con Docker y docker compose.
Antes de empezar,
[debemos instalar Docker Desktop](https://docs.docker.com/desktop/).

## Definir los componentes del proyecto
Para este proyecto, debe crear un Dockerfile, un archivo de dependencias de Python,
y un archivo `docker-compose.yml`. (Puede usar una extensión `.yml` o `.yaml` para este archivo).

1. Cree un directorio de proyecto vacío.

     Puede nombrar el directorio algo fácil de recordar. Este directorio es el contexto de la imagen de su aplicación. El directorio solo debe contener recursos para construir esa imagen.

2. Cree un nuevo archivo llamado `Dockerfile` en el directorio de su proyecto.

El Dockerfile define el contenido de la imagen de una aplicación a través de una o más compilaciones y comandos que configuran esa imagen.
Una vez construida, puede ejecutar la imagen en un contenedor. Para obtener más información sobre `Dockerfile`, consulte la [Guía del usuario de Docker] (https://docs.docker.com/get-started/) y la [referencia de Dockerfile](https://docs.docker.com/engine/reference/builder/).

3. Agregue el siguiente contenido al `Dockerfile`.
```dockerfile
   FROM python:3
   ENV PYTHONDONTWRITEBYTECODE=1
   ENV PYTHONUNBUFFERED=1
   WORKDIR /code
   COPY requirements.txt /code/
   RUN pip install -r requirements.txt
   COPY . /code/
```
Este `Dockerfile` comienza con una [imagen principal de Python 3] (https://hub.docker.com/r/library/python/tags/3/).
    La imagen principal se modifica agregando un nuevo directorio `code`. La imagen principal se modifica aún más.
    instalando los requisitos de Python definidos en el archivo `requirements.txt`.
4. Guarde y cierre el `Dockerfile`.
5. Cree un archivo `requirements.txt` en el directorio.

Este archivo es utilizado por el comando `RUN pip install -r requirements.txt` en su `Dockerfile`.

6. Agregue los paquetes de python requeridos en el archivo (En este caso son los paquetes minimos para crear un nuevo proyecto de Django desde cero).
```python
Django>=3.0,<4.0
psycopg2>=2.8
```
7. Guarde y cierre el archivo `requirements.txt`.
8. Cree un archivo llamado `docker-compose.yml` en el directorio de su proyecto.

El archivo `docker-compose.yml` describe los servicios que componen su aplicación. En
este ejemplo, esos servicios son un servidor web y una base de datos. El archivo de redacción
 también describe qué imágenes de Docker utilizan estos servicios, cómo se vinculan
 juntos, los volúmenes que puedan necesitar para ser montados dentro de los contenedores.
 Finalmente, el archivo `docker-compose.yml` describe qué puertos estos servicios
 exponer. Consulte la referencia de [`docker-compose.yml`](https://docs.docker.com/compose/compose-file/) para obtener más información.
 información sobre cómo funciona este archivo.

9. Agregue la siguiente configuración al archivo.


```yaml
services:
 db:
   image: postgres
   volumes:
     - ./data/db:/var/lib/postgresql/data
   environment:
     - POSTGRES_DB=postgres
     - POSTGRES_USER=postgres
     - POSTGRES_PASSWORD=postgres
 web:
   build: .
   command: python manage.py runserver 0.0.0.0:8000
   volumes:
     - .:/code
   ports:
     - "8000:8000"
   environment:
     - POSTGRES_NAME=postgres
     - POSTGRES_USER=postgres
     - POSTGRES_PASSWORD=postgres
   depends_on:
     - db
```
Este archivo define dos servicios: el servicio `db` y el servicio `web`.

10. Guarde y cierre el archivo `docker-compose.yml`.

## Crear un proyecto Django

Ahora vamos a crear un proyecto en blanco de Django, compilando la imagen a partir del contexto de lo definido anteriormente

1. Vamos a la raíz del directorio.
2. Cree el proyecto Django ejecutando [docker compose run](https://docs.docker.com/engine/reference/commandline/compose_run/)
    comando de la siguiente manera.
```console
docker compose run web django-admin startproject miproyectonuevo .
```
 Esto le indica a Compose que ejecute `django-admin startproject miproyectonuevo`
 en un contenedor, usando la imagen y configuración del servicio `web`. Porque
 la imagen `web` que aún no existe, Compose la crea a partir del directorio actual, como se especifica en la línea `build: .` en `docker-compose.yml`. 
 Una vez que se crea la imagen del servicio `web`, Compose la ejecuta y ejecuta el Comando `django-admin startproject` en el contenedor. Este comando
 le indica a Django que cree un conjunto de archivos y directorios que representen un Proyecto Django.

3. Después de que se complete el comando `docker compose`, listamos el contenido de su proyecto.
```console
$ ls -l

drwxr-xr-x 2 root   root   miproyectonuevo
drwxr-xr-x 3 root   root   data
-rw-rw-r-- 1 user   user   docker-compose.yml
-rw-rw-r-- 1 user   user   Dockerfile
-rwxr-xr-x 1 root   root   manage.py
-rw-rw-r-- 1 user   user   requirements.txt
```

### Conectar la base de datos

En esta sección, configuraremos la conexión de la base de datos para Django.

1. En el directorio de su proyecto, edite el archivo `miproyectonuevo/settings.py`.

2. Reemplazamos `DATABASES = ...` con lo siguiente:
```python
# settings.py

import os

[...]

DATABASES = {
   'default': {
       'ENGINE': 'django.db.backends.postgresql',
       'NAME': os.environ.get('POSTGRES_NAME'),
       'USER': os.environ.get('POSTGRES_USER'),
       'PASSWORD': os.environ.get('POSTGRES_PASSWORD'),
       'HOST': 'db',
       'PORT': 5432,
   }
}
```
Estos ajustes están determinados por el
[postgres](https://hub.docker.com/_/postgres) Imagen de Docker especificado en `docker-compose.yml`.

3. Guarde y cierre el archivo.

4. Ejecute el comando [docker compose up](https://docs.docker.com/engine/reference/commandline/compose_up/) desde el directorio del proyecto.
```console
$ docker compose up

djangosample_db_1 is up-to-date
Creating djangosample_web_1 ...
Creating djangosample_web_1 ... done
Attaching to djangosample_db_1, djangosample_web_1
db_1   | The files belonging to this database system will be owned by user "postgres".
db_1   | This user must also own the server process.
db_1   |
db_1   | The database cluster will be initialized with locale "en_US.utf8".
db_1   | The default database encoding has accordingly been set to "UTF8".
db_1   | The default text search configuration will be set to "english".

<...>

web_1  | July 18, 2023 - 19:50:38
web_1  | Django version 3.0.8, using settings 'miproyectonuevo.settings'
web_1  | Starting development server at http://0.0.0.0:8000/
web_1  | Quit the server with CONTROL-C.
```
 En este punto, su aplicación Django debería estar ejecutándose en el puerto `8000`.
 
> Nota:
    >
    > En ciertas plataformas (Windows 10), es posible que deba editar `ALLOWED_HOSTS`
    > dentro de `settings.py` y agregue su nombre de host Docker o dirección IP a la lista.
    > Para fines de demostración, puede establecer el valor en:
    >
    > ```python
    > ALLOWED_HOSTS = ['*']
    > ```
    >
    > Este valor **no** es seguro para uso en producción. Referirse a
    > [Documentación de Django](https://docs.djangoproject.com/en/1.11/ref/settings/#allowed-hosts) para obtener más información.

5. Enumere los contenedores en funcionamiento.

En otra ventana de terminal, enumere los procesos de Docker en ejecución con el comando `docker ps` o `docker container ls`.

```console
   $ docker ps

   CONTAINER ID  IMAGE       COMMAND                  CREATED         STATUS        PORTS                    NAMES
   def85eff5f51  django_web  "python3 manage.py..."   10 minutes ago  Up 9 minutes  0.0.0.0:8000->8000/tcp   django_web_1
   678ce61c79cc  postgres    "docker-entrypoint..."   20 minutes ago  Up 9 minutes  5432/tcp                 django_db_1
   ```

6. Apague los servicios y límpielos usando cualquiera de estos métodos:

     * Detenga la aplicación escribiendo `Ctrl-C` en la misma terminal donde ejecutamos los servicios:
    ```console
    Gracefully stopping... (press Ctrl+C again to force)
    Killing test_web_1 ... done
    Killing test_db_1 ... done
    ```
   * O, cambie a un shell diferente y ejecute
   [docker compose down](https://docs.docker.com/engine/reference/commandline/compose_down/) desde la raiz del proyecto.
     ```console
      $ docker compose down

      Stopping django_web_1 ... done
      Stopping django_db_1 ... done
      Removing django_web_1 ... done
      Removing django_web_run_1 ... done
      Removing django_db_1 ... done
      Removing network django_default
      ```
