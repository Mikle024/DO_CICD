# CI/CD:

----------------------------------------------------------------------------

- [CI/CD:](#SimpleDocker)
    - [1. Настройка gitlab-runner:](#1-настройка-gitlab-runner)
    - [2. Сборка:](#2-сборка)
    - [3. Тест кодстайла:](#3-тест-кодстайла)
    - [4. Интеграционные тесты:](#4-интеграционные-тесты)
    - [5. Этап деплоя:](#5-этап-деплоя)
    - [6. Уведомления:](#6-уведомления)

----------------------------------------------------------------------------

## 1. Настройка gitlab-runner:
- Поднял виртуальную машину **Ubuntu Server 22.04 LTS**.

> Версия VM:
>
> ![Версия VM](screen%2Fscreen_1_01.png)
>

- Для установки **gitlab-runner** воспользовался официальной документацией с [сайта GitLab](https://docs.gitlab.com/runner/install/linux-repository.html).
- Добавил официальный репозиторий **GitLab** командой `curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash`.

> Packages **GitLab**:
>
> ![Packages GitLab](screen%2Fscreen_1_02.png)
>

- Установил **gitlab-runner** командой `sudo apt install gitlab-runner`.

> Установка **gitlab-runner**:
>
> ![Установка gitlab-runner](screen%2Fscreen_1_03.png)
>

- Зарегистрировал **gitlab-runner** для использования в текущем проекте командой `sudo gitlab-runner register`.
- Указав: **URL** GitLab сервера - `https://repos.21-school.ru`, **токен** проекта, **описание**, **теги**, и **executor** (*механизм, с помощью которого будет запущен код проекта*) - `shell`.

> Регистрация **gitlab-runner**:
>
> ![Регистрация gitlab-runner](screen%2Fscreen_1_04.png)
>

- Выполнил команду `sudo gitlab-runner verify`, для проверки состояния всех зарегистрированных **GitLab Runners**.
- Проверил работу сервиса **gitlab-runner** командой `systemctl status gitlab-runner`.

> Успешный запуск и регистрация **gitlab-runner**:
>
> ![Успешный запуск и регистрация gitlab-runner](screen%2Fscreen_1_05.png)
>

----------------------------------------------------------------------------

## 2. Сборка:
- Поместил в `src` директории `cat` и `grep` из своего проекта **C2_SimpleBashUtils**.
- Написал `.gitlab-ci.yml` с этапом сборки приложений `s21_cat` и `s21_grep`, поместив файл в корень репозитория текущего проекта.

> Написанный файл `.gitlab-ci.yml`:
>
> ![Написанный файл .gitlab-ci.yml](screen%2Fscreen_2_01.png)
>

```yml
default:                 # Задает параметры по умолчанию для всех джобов
  tags: [build]          # Тег, который будет использоваться для выбора раннера с таким тегом

stages:                  # Определяет стадии выполнения пайплайна
  - build                # Первая (и единственная в этом случае) стадия — сборка

build_job:               # Имя джоба, который будет выполняться на стадии "build"
  stage: build           # Назначает джоб на стадию "build"
  script:                # Определяет список команд, которые нужно выполнить в этом джобе
    - rm -fr artifacts   # Удаляет директорию "artifacts", если она существует
    - mkdir artifacts    # Создает новую пустую директорию "artifacts"
    - (cd src/cat && make clean && make s21_cat)  # Переходит в папку src/cat, выполняет очистку и собирает утилиту s21_cat
    - (cd src/grep && make clean && make s21_grep)  # Переходит в папку src/grep, выполняет очистку и собирает утилиту s21_grep
    - cp src/cat/s21_cat src/grep/s21_grep artifacts  # Копирует собранные утилиты s21_cat и s21_grep в директорию artifacts
  artifacts:             # Настройки артефактов, которые будут сохраняться после выполнения джоба
    paths:               # Указывает, какие файлы или директории нужно сохранить как артефакты
      - artifacts        # Сохраняет директорию "artifacts", содержащую собранные утилиты
    expire_in: 30 days   # Устанавливает срок хранения артефактов — 30 дней
  only:                  # Указывает, что джоб должен запускаться только при пушах в определенные ветки
    - develop            # Джоб будет выполняться только при пушах в ветку "develop"
```

- Установил `gcc` и `make` на виртуальную машину с `gitlab-runner`.

> Установка `gcc`:
>
> ![Установка gcc](screen%2Fscreen_2_02.png)
> 
> Установка `make`:
> 
> ![Установка make](screen%2Fscreen_2_03.png)

- Закоммитил и запушил изменения текущего проекта на **гитлаб** с включенной виртуальной машиной. 

> Push in **gitlab**:
>
> ![Push in gitlab](screen%2Fscreen_2_04.png)
>

> Успешно отработанный пайплайн:
>
> ![Успешно отработанный пайплайн_1](screen%2Fscreen_2_05.png)
>
> ![Успешно отработанный пайплайн_2](screen%2Fscreen_2_06.png)
>

> Файлы, полученные после сборки (артефакты) сохранены в директорию `artifacts`, со сроком хранения 30 дней:
>
> ![artifacts_1](screen%2Fscreen_2_07.png)
> 
> ![artifacts_2](screen%2Fscreen_2_08.png)
>
> ![artifacts_3](screen%2Fscreen_2_09.png)
>

----------------------------------------------------------------------------

## 3. Тест кодстайла:
- Изменил `.gitlab-ci.yml`, написав этап, который запускает скрипт кодстайла (clang-format).

> Измененный файл `.gitlab-ci.yml`:
>
> ![Измененный файл .gitlab-ci.yml](screen%2Fscreen_3_01.png)
>

- Флаг `--Werror` в команде `clang-format -n --Werror --verbose src/cat/*.c src/grep/*.c` приводит к тому, что при нарушении форматирования команда `clang-format` завершится с кодом ошибки `1`, что автоматически фейлит `job`.

```yml
default:
  tags: [build]

stages:
  - build
  - code_style # Этап проверки кодстайла

build_job:
  stage: build
  script:
    - rm -fr artifacts
    - mkdir artifacts
    - (cd src/cat && make clean && make s21_cat)
    - (cd src/grep && make clean && make s21_grep)
    - cp src/cat/s21_cat src/grep/s21_grep artifacts
  artifacts:
    paths:
      - artifacts
    expire_in: 30 days
  only:
    - develop

clang_format_job:
  stage: code_style # Этап проверки кодстайла
  script:
    - echo "Running clang-format check..." # Сообщение о запуске проверки clang-format
    - |
      if clang-format -n --Werror --verbose src/cat/*.c src/grep/*.c; then
        echo "Clang-format check passed."
      else
        echo "clang-format check failed."
        exit 1
      fi
  only:
    - develop # Пайплайн запускается только для ветки develop
  allow_failure: false # Если текущий job фейлится, то фейлим весь пайплайн
# Если кодстайл правильный, выводим сообщение о прохождении проверки
# Если найдены проблемы с кодстайлом, завершаем выполнение с ошибкой (job зафейлится)
```

- Специально не копировал файл `.clang-format` из директории `materials/linters/`, для проверки, если `job` кодстайла не прошел, «зафейлится» ли пайплайн.
<br><br>
- Установил `clang-format` на виртуальную машину с `gitlab-runner`.

> Установка `clang-format`:
>
> ![Установка clang-format](screen%2Fscreen_3_02.png)
>

- Закоммитил и запушил изменения файла `.gitlab-ci.yml` на **гитлаб** с включенной виртуальной машиной.

> Commit and push in **gitlab**:
>
> ![Push in gitlab](screen%2Fscreen_3_03.png)
>

> «Зафейленный» пайплайн:
>
> ![Зафейленный пайплайн_1](screen%2Fscreen_3_04.png)
>
> ![Зафейленный пайплайн_2](screen%2Fscreen_3_05.png)
>

- `build_job` прошел успешно, а `clang_format_job` «зафейлился», поэтому пайплайн тоже со статусом `failed`.

> «Зафейленный» `clang_format_job`:
>
> ![Зафейленный clang_format_job](screen%2Fscreen_3_06.png)
>

- Изменил `.gitlab-ci.yml`, добавив команды, которые копируют файл `.clang-format` из директории `materials/linters/`.

> Измененный файл `.gitlab-ci.yml`:
>
> ![Измененный файл .gitlab-ci.yml](screen%2Fscreen_3_07.png)
>

```yml
clang_format_job:
  stage: code_style
  script:
    - cp materials/linters/.clang-format src/cat/ # Копирование .clang-format в папку cat
    - cp materials/linters/.clang-format src/grep/ # Копирование .clang-format в папку grep
    - echo "Running clang-format check..."
    - |
      if clang-format -n --Werror --verbose src/cat/*.c src/grep/*.c; then
        echo "Clang-format check passed."
      else
        echo "clang-format check failed."
        exit 1
      fi
  only:
    - develop
  allow_failure: false
```

- Закоммитил и запушил изменения файла `.gitlab-ci.yml` на **гитлаб**.

> Успешно отработанный пайплайн:
>
> ![Успешно отработанный пайплайн_1](screen%2Fscreen_3_08.png)
>
> ![Успешно отработанный пайплайн_2](screen%2Fscreen_3_09.png)
>

> Успешно отработанный `clang_format_job`:
>
> ![Успешно отработанный clang_format_job](screen%2Fscreen_3_10.png)
>

----------------------------------------------------------------------------

## 4. Интеграционные тесты:
- Изменил `.gitlab-ci.yml`, написав этап, который запускает интеграционные тесты из проекта **C2_SimpleBashUtils**.

> Измененный файл `.gitlab-ci.yml`:
>
> ![Измененный файл .gitlab-ci.yml](screen%2Fscreen_4_01.png)
>

```yml
default:
  tags: [build]

stages:
  - build
  - code_style
  - test # Этап тестирования

build_job:
  stage: build
  script:
    - rm -fr artifacts
    - mkdir artifacts
    - (cd src/cat && make clean && make s21_cat)
    - (cd src/grep && make clean && make s21_grep)
    - cp src/cat/s21_cat src/grep/s21_grep artifacts
  artifacts:
    paths:
      - artifacts
    expire_in: 30 days
  only:
    - develop

clang_format_job:
  stage: code_style
  script:
    - cp materials/linters/.clang-format src/cat/
    - cp materials/linters/.clang-format src/grep/
    - echo "Running clang-format check..."
    - |
      if clang-format -n --Werror --verbose src/cat/*.c src/grep/*.c; then
        echo "Clang-format check passed."
      else
        echo "clang-format check failed."
        exit 1
      fi
  only:
    - develop
  allow_failure: false

integration_test_job:
  stage: test # Этап тестирования
  script:
    - echo "Running integration tests..."  # Выводит сообщение о запуске интеграционных тестов
    - set -e  # Указывает на завершение скрипта при любой ошибке команды (чтобы остановить выполнение при ошибках)
    - (cd src/cat && make test) || { echo "Integration tests for s21_cat failed."; exit 1; }  # Переходит в директорию "cat" и запускает тесты. Если они провалятся, выводится сообщение об ошибке и выполнение скрипта останавливается
    - (cd src/grep && make test) || { echo "Integration tests for s21_grep failed."; exit 1; }  # Переходит в директорию "grep" и запускает тесты. Если они провалятся, выводится сообщение об ошибке и выполнение скрипта останавливается
    - echo "All integration tests passed successfully."  # Выводит сообщение об успешном прохождении всех интеграционных тестов
  only:
    - develop # Пайплайн запускается только для ветки develop
  dependencies:
    - build_job  # job запустится только при условии, если сборка прошла успешно
    - clang_format_job  # job запустится только при условии, если кодстайл прошел успешно
  allow_failure: false  # Если текущий job фейлится, то фейлим весь пайплайн
```

- Что бы текущий **job** «фейлился», укажем в **скрипте** с тестами код выхода с ошибкой, в случае, если хоть один тест упадет.

> Файл `tests_script_cat.sh`:
>
> ![Файл tests_script_cat.sh](screen%2Fscreen_4_02.png)
>

> Файл `tests_script_grep.sh`:
>
> ![Файл tests_script_grep.sh](screen%2Fscreen_4_03.png)
>

- Оставил один зафейленный тест для **s21_cat**.
- Закоммитил и запушил изменения на **гитлаб**.


> «Зафейленный» пайплайн:
>
> ![Зафейленный пайплайн_1](screen%2Fscreen_4_04.png)
>
> ![Зафейленный пайплайн_2](screen%2Fscreen_4_05.png)
>
> ![Зафейленный пайплайн_3](screen%2Fscreen_4_06.png)
>
> **Скрипт** завершается с кодом ошибки `1`. Выводится информация, что интеграционные тесты `s21_cat` **провалились**. **Job** завершается с **ошибкой**.
>

- Оставил один зафейленный тест для **s21_grep**.
- Закоммитил и запушил изменения на **гитлаб**.

> «Зафейленный» пайплайн:
>
> ![Зафейленный пайплайн_1](screen%2Fscreen_4_07.png)
>
> ![Зафейленный пайплайн_2](screen%2Fscreen_4_08.png)
>
> ![Зафейленный пайплайн_3](screen%2Fscreen_4_09.png)
>
> **Скрипт** завершается с кодом ошибки `1`. Выводится информация, что интеграционные тесты `s21_grep` **провалились**. **Job** завершается с **ошибкой**.
>

- Исправил все тесты на **SUCCESSFUL**.
- Закоммитил и запушил изменения на **гитлаб**.

> Успешно отработанный пайплайн:
>
> ![Успешно отработанный пайплайн_1](screen%2Fscreen_4_10.png)
>
> ![Успешно отработанный пайплайн_2](screen%2Fscreen_4_11.png)
>
> ![Успешно отработанный пайплайн_3](screen%2Fscreen_4_12.png)
>
> Выводится информация, что интеграционные тесты **прошли успешно**. **Job** завершается без **ошибки**.
>

----------------------------------------------------------------------------

## 5. Этап деплоя:

----------------------------------------------------------------------------

## 6. Уведомления:

----------------------------------------------------------------------------
