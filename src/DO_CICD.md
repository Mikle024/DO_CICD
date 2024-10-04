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
- Поднял вторую виртуальную машину **Ubuntu Server 22.04 LTS**.

> Версия VM:
>
> ![Версия VM](screen%2Fscreen_5_01.png)
>

- Объединил две виртуальные машины одной **сетью**.

<details><summary><strong>Процесс создания одной сети:</strong></summary>

- Добавил новые интерфейсы для каждой виртуальной машины, с типом подключения "Внутренняя сеть".

> Добавление интерфейса для **VM1**:
>
> ![Добавление интерфейса VM1](screen%2Fscreen_5_02.png)
> 
> Добавление интерфейса **VM2**:
> 
> ![Добавление интерфейса VM2](screen%2Fscreen_5_03.png)
> 

- Изменил настройки **netplan** для каждой виртуальной машины, прописав статические `ip-адреса` в диапазоне одной сети. 

> Файл `/etc/netplan/50-cloud-init.yaml` для **VM1**:
>
> ![Файл /etc/netplan/50-cloud-init.yaml VM1](screen%2Fscreen_5_04.png)
>
> Файл `/etc/netplan/50-cloud-init.yaml` **VM2**:
>
> ![Файл /etc/netplan/50-cloud-init.yaml VM2](screen%2Fscreen_5_05.png)
>

- Применил настройки **netplan** командой `sudo netplan apply` для каждой **ВМ**.
- Что бы настройки не изменялись после каждого **перезапуска ВМ** прописал те же настройки в файл `/etc/cloud/cloud.cfg.d/90-installer-network.cfg`.

> Статический `ip-адрес` **VM1**:
>
> ![Статический ip-адрес VM1](screen%2Fscreen_5_06.png)
>
> Статический `ip-адрес` **VM2**:
>
> ![Статический ip-адрес VM2](screen%2Fscreen_5_07.png)
>

</details>

- Пропинговал каждую машину друг с другом.

> Успешный пинг **VM2** с **VM1**:
>
> ![Успешный пинг VM2 с VM1](screen%2Fscreen_5_08.png)
>
> Успешный пинг **VM1** с **VM2**:
>
> ![Успешный пинг VM1 с VM2](screen%2Fscreen_5_09.png)
>

- Для переноса **артефактов** с первой ВМ на вторую, установил на вторую ВМ сервис `ssh`.

> Статус сервиса `ssh` **VM2**:
>
> ![Статус сервиса ssh VM2](screen%2Fscreen_5_10.png)
>
- Написал `bash-script` `deploy_to_second_vm.sh` для копирования артефактов.

> Скрипт `src/deploy_to_second_vm.sh`:
>
> ![Скрипт src/deploy_to_second_vm.sh](screen%2Fscreen_5_11.png)
>

```bash
#!/bin/bash

REMOTE_USER="mikle"                   # Имя пользователя для SSH подключения к удалённой машине
REMOTE_HOST="192.168.0.180"            # IP-адрес удалённой машины
REMOTE_DIR="/usr/local/bin"            # Директория на удалённой машине, куда будут копироваться файлы
ARTIFACTS_DIR="/home/gitlab-runner/builds/H88J4gtA/0/students/
DO6_CICD.ID_356283/onionyas_student.21_school.ru/DO6_CICD-1/artifacts"  # Директория, содержащая артефакты

# Проверка наличия директории с артефактами
if [ -d "$ARTIFACTS_DIR" ]; then
        echo "Artifacts found, start copy.."  # Сообщение о том, начинается процесс копирования

        # Копирование артефактов s21_cat и s21_grep с помощью scp
        scp "$ARTIFACTS_DIR/s21_cat" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" && \
        scp "$ARTIFACTS_DIR/s21_grep" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

        # Проверка, что команда scp завершилась успешно
        if [ $? -eq 0 ]; then
                echo "COPY SUCCESSFUL"  # Если копирование прошло успешно, выводим сообщение
        else
                echo "COPY FAIL"  # Если возникла ошибка, выводим сообщение и выходим с кодом ошибки
                exit 1
        fi
else
        echo "NO ARTIFACTS FOUND"  # Если директория с артефактами не найдена, выводим сообщение и завершаем скрипт с кодом ошибки
        exit 1
fi

# Проверяем что файлы скопированы
ssh $REMOTE_USER@$REMOTE_HOST ls -la $REMOTE_DIR
```

- Что бы скрипт работал самостоятельно без запроса паролей и дополнительных взаимодействий, настроил все необходимы права.
- Так как `gitlab-runner` на **ВМ** запускается от имени пользователя "*gitlab-runner*", переключился на этого пользователя, предварительно задав ему пароль.

> Пользователь `gitlab-runner`:
>
> ![Пользователь gitlab-runner](screen%2Fscreen_5_12.png)
>

**Перед копированием ключа `id_rsa.pub` необходимо один раз подключиться по `SSH`, чтобы хост был добавлен в файл `known_hosts` на второй ВМ. Это нужно для установления доверия между хостами, что позволит выполнять дальнейшие соединения и передавать ключи для настройки авторизации без пароля.**

- Подключился ко второй **ВМ** по `SSH` командой `ssh user@ip-addresses`.
- Разорвал соединение командой `exit`.

> Подключение по `SSH`:
>
> ![Подключение по SSH](screen%2Fscreen_5_13.png)
>

- Сгенерировал ключи `SSH` командой `ssh-keygen`.
- Перенёс публичный ключ на вторую **ВМ** командой `ssh-copy-id user@ip-addresses`.

**Команда `ssh-copy-id` автоматически копирует публичный ключ `SSH` на удалённую машину. Это позволяет в дальнейшем подключаться к этому серверу по SSH без необходимости вводить пароль, используя ключевую аутентификацию.**

> Копирование публичного ключа `SSH`:
>
> ![Копирование публичного ключа SSH](screen%2Fscreen_5_14.png)
>

- Для копирования артефактов в директорию `/usr/local/bin` на второй **ВМ**, сменил владельца этой директории на пользователя, под которым будем выполнять подключение по `SSH`, чтобы предоставить ему необходимые права на запись.

> Смена владельца директории командой `sudo chown -R [USER] [DIRECTORY]`:
>
> ![Смена владельца](screen%2Fscreen_5_15.png)
>

- Проверил вручную копирование артефакта `s21_cat` с первой **ВМ** на вторую, чтобы убедиться, что операция выполняется успешно и без запроса пароля.

> Успешное копирование артефакта `s21_cat`:
>
> ![Успешное копирование артефакта s21_cat](screen%2Fscreen_5_16.png)
>

- Изменил `.gitlab-ci.yml`, написав этап, который «разворачивает» проект на второй **ВМ**. Он будет запускаться вручную при условии, что все предыдущие этапы прошли успешно.

> Измененный файл `.gitlab-ci.yml`:
>
> ![Измененный файл .gitlab-ci.yml](screen%2Fscreen_5_17.png)
>

```yaml
default:
  tags: [build]

stages:
  - build
  - code_style
  - test
  - deploy # Этап деплоя

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
  stage: test
  script:
    - echo "Running integration tests..."
    - set -e
    - (cd src/cat && make test) || { echo "Integration tests for s21_cat failed."; exit 1; }
    - (cd src/grep && make test) || { echo "Integration tests for s21_grep failed."; exit 1; }
    - echo "All integration tests passed successfully."
  only:
    - develop
  dependencies:
    - build_job
    - clang_format_job
  allow_failure: false

deploy_job:
  stage: deploy # Этап деплоя
  script:
    - echo "Deploying to the second virtual machine..."
    - chmod +x src/deploy_to_second_vm.sh # Даем права доступа скрипту
    - bash src/deploy_to_second_vm.sh # Запускаем скрипт копирования артефектов на вторую ВМ
  when: manual  # job запускать вручную
  only:
    - develop  # Пайплайн запускается только для ветки develop
  dependencies:
    - build_job  # job запустится только при условии, если сборка прошла успешно
    - clang_format_job  # job запустится только при условии, если кодстайл прошел успешно
    - integration_test_job  # job запустится только при условии успешного завершения тестов
  allow_failure: false  # Если текущий job фейлится, то фейлим весь пайплайн
```

- Закоммитил и запушил изменения на **гитлаб**.

> Все этапы отработали, этап деплоя ждет ручного запуска:
>
> ![Успешно отработанный пайплайн_1](screen%2Fscreen_5_18.png)
>
> ![Успешно отработанный пайплайн_2](screen%2Fscreen_5_19.png)
>
> Ручной запуск этапа **deploy**:
> 
> ![Успешно отработанный пайплайн_3](screen%2Fscreen_5_20.png)
> 
> Успешно отработанный этап **deploy**:
> 
> ![Успешно отработанный пайплайн_4](screen%2Fscreen_5_21.png)
> 
> ![Успешно отработанный пайплайн_5](screen%2Fscreen_5_22.png)
> 

- Проверил копирование артефактов на вторую **ВМ**.

> Успешное копирование артефактов после отработанного **пайплайна**:
>
> ![Успешное копирование артефактов](screen%2Fscreen_5_23.png)
>

- Сохранил дампы образов виртуальных машин.

> Сохранение дампа образа **VM1**:
>
> ![Сохранение дампа образа VM1](screen%2Fscreen_5_24.png)
>
> Сохранение дампа образа **VM2**:
> 
> ![Сохранение дампа образа VM2](screen%2Fscreen_5_25.png)
> 

----------------------------------------------------------------------------

## 6. Уведомления:
- Нашел в **telegram** `@BotFather`, и создал нового бота с помощью команды `/newbot`.
- С помощью бота `@userinfobot` узнал `id` своего **telegram**-аккаунта командой `/start`.
<br><br>
- Написал `bash-script` `telegram_notify.sh` для отправки уведомлений об успешном/неуспешном выполнении всех этапов и пайплайна.

> Скрипт `src/telegram_notify.sh`:
>
> ![Скрипт src/telegram_notify.sh](screen%2Fscreen_6_01.png)
>

```bash
#!/bin/bash

BOT_TOKEN="[YOUR_BOT_TOKEN]" # Вставить нужный токен
CHAT_ID="[YOUR_TELEGRAM_ID]" # Вставить нужный id

# Устанавливаем максимальное время ожидания выполнения команды curl (в секундах)
TIME="10"

# Формируем URL для отправки сообщений боту Telegram
URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

BUILD_STATUS="✅ Success"  # Статус этапа сборки
CODE_STYLE_STATUS="✅ Success"  # Статус этапа проверки стиля кода
TEST_STATUS="✅ Success"  # Статус этапа тестирования
DEPLOY_STATUS="✅ Success"  # Статус этапа развертывания

# Создаем текст уведомления с деталями о пайплайне
TEXT="Pipeline Status Notification:
Project: $CI_PROJECT_NAME
Pipeline URL: $CI_PIPELINE_URL

Build Stage: $BUILD_STATUS
- Details: Build completed successfully, artifacts copied.

Code Style Stage: $CODE_STYLE_STATUS
- Details: Code style check completed successfully.

Test Stage: $TEST_STATUS  # Статус этапа тестирования
- Details: All integration tests passed successfully.

Deploy Stage: $DEPLOY_STATUS  # Статус этапа развертывания
- Details: Artifacts successfully deployed to the second virtual machine.

--------------------"

# Отправляем сформированное сообщение в чат Telegram
curl -s -m $TIME -d "chat_id=$CHAT_ID&disable_web_page_preview=1&text=$TEXT" $URL > /dev/null
```

- Изменил `.gitlab-ci.yml`, дописав этап, который запустит скрипт.

> Измененный файл `.gitlab-ci.yml`:
>
> ![Измененный файл .gitlab-ci.yml](screen%2Fscreen_6_02.png)
>

```yaml
default:
  tags: [build]

stages:
  - build
  - code_style
  - test
  - deploy
  - notify  # Этап отправки уведомлений об успешном/неуспешном выполнении пайплайна

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
  stage: test
  script:
    - echo "Running integration tests..."
    - set -e
    - (cd src/cat && make test) || { echo "Integration tests for s21_cat failed."; exit 1; }
    - (cd src/grep && make test) || { echo "Integration tests for s21_grep failed."; exit 1; }
    - echo "All integration tests passed successfully."
  only:
    - develop
  dependencies:
    - build_job
    - clang_format_job
  allow_failure: false

deploy_job:
  stage: deploy
  script:
    - echo "Deploying to the second virtual machine..."
    - chmod +x src/deploy_to_second_vm.sh
    - bash src/deploy_to_second_vm.sh
  when: manual
  only:
    - develop
  dependencies:
    - build_job
    - clang_format_job
    - integration_test_job
  allow_failure: false

notify_job:
  stage: notify # Этап отправки уведомлений об успешном/неуспешном выполнении пайплайна
  script:
    - echo "Sending notification to Telegram..."
    - chmod +x src/telegram_notify.sh # Даем права доступа скрипту
    - bash src/telegram_notify.sh # Запускаем скрипт отправки уведомлений в telegram
  when: always job запускается всегда
  only:
    - develop  # Пайплайн запускается только для ветки develop
  dependencies:
    - build_job # job запустится только при условии, если сборка прошла успешно
    - clang_format_job # job запустится только при условии, если кодстайл прошел успешно
    - integration_test_job # job запустится только при условии успешного завершения тестов
    - deploy_job # job запустится только при условии успешного завершения деплоя
```

- Закоммитил и запушил изменения на **гитлаб**.

> Успешно отработанный пайплайн:
>
> ![Успешно отработанный пайплайн_1](screen%2Fscreen_6_03.png)
>
> ![Успешно отработанный пайплайн_2](screen%2Fscreen_6_04.png)
>

> Сообщение от **telegram-бота** с информацией о пайплайне **"CI/CD"**:
>
> ![Измененный файл .gitlab-ci.yml](screen%2Fscreen_6_05.png)
>

----------------------------------------------------------------------------
