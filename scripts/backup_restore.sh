#!/bin/bash
# Создание резервной копии базы данных
docker compose exec -T db pg_dump -U postgres -Fc app > backup.dump

# Восстановление базы данных из резервной копии
docker compose exec -T db pg_restore -U postgres -d app < backup.dump