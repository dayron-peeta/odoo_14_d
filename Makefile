# Cargar variables desde el archivo .env
include .env
export $(shell sed 's/=.*//' .env)

# Actualizar módulos de una bd Odoo
ODOO_CONTAINER ?= ${COMPOSE_PROJECT_NAME}-odoo-1
DB_NAME ?= odoo14
MODULE ?= all

update-odoo-modules:
	@read -p "-----[INPUT] Enter the container name (default: $(ODOO_CONTAINER)): " input; \
	ODOO_CONTAINER=$${input:-$(ODOO_CONTAINER)}; \
	read -p "-----[INPUT] Enter the database name (default: $(DB_NAME)): " input; \
	DB_NAME=$${input:-$(DB_NAME)}; \
	read -p "-----[INPUT] Enter the module to update (default: $(MODULE)): " input; \
	MODULE=$${input:-$(MODULE)}; \
	echo "-----[INFO] Updating module(s) '$$MODULE' in database '$$DB_NAME' inside container '$$ODOO_CONTAINER'..."; \
	docker exec -it $$ODOO_CONTAINER bash -c "/usr/bin/odoo -c /etc/odoo/odoo.conf -d $$DB_NAME -u $$MODULE --stop-after-init"; \
	echo "-----[SUCCESS] Update completed."

.PHONY: update-odoo-modules

# Inicializar la base de datos
init-db:
	@echo "🔄 Inicializando la base de datos '$(DB_NAME)' en el contenedor '$(ODOO_CONTAINER)' con usuario '$(DB_USER)'..."
	docker exec -it $(ODOO_CONTAINER) odoo -i base --db_host=$(DB_HOST) --db_user=$(DB_USER) --db_password=$(DB_PASSWORD) -d $(DB_NAME) --stop-after-init
	@echo "✅ Base de datos '$(DB_NAME)' inicializada correctamente."

.PHONY: init-db

# Crear una nueva base de datos
create-db:
	@read -p "-----[INPUT] Enter the database name to create: " dbname; \
	echo "🔄 Creating database '$$dbname'..."; \
	docker exec -it $(POSTGRES_CONTAINER) createdb -U $(DB_USER) $$dbname; \
	echo "✅ Database '$$dbname' created successfully."

.PHONY: create-db

# Ejecutar Docker Compose
docker-up:
	docker-compose up -d
	@echo "✅ Containers started successfully"

.PHONY: docker-up

docker-down:
	docker-compose down
	@echo "✅ Containers stopped successfully"

.PHONY: docker-down

docker-restart:
	docker-compose restart
	@echo "✅ Containers restarted successfully"

.PHONY: docker-restart

# Ver logs de Odoo
logs-odoo:
	docker-compose logs odoo -f

.PHONY: logs-odoo

# Ver logs de PostgreSQL
logs-postgres:
	docker-compose logs postgres -f

.PHONY: logs-postgres

# Acceder a la terminal de Odoo
bash-odoo:
	docker exec -it $(ODOO_CONTAINER) bash

.PHONY: bash-odoo

# Acceder a la terminal de PostgreSQL
bash-postgres:
	docker exec -it $(POSTGRES_CONTAINER) bash

.PHONY: bash-postgres

# Acceder a la base de datos con psql
psql:
	docker exec -it $(POSTGRES_CONTAINER) psql -U $(DB_USER) $(DB_NAME)

.PHONY: psql

# Backup de la base de datos
backup-db:
	@read -p "-----[INPUT] Enter the database name to backup (default: $(DB_NAME)): " input; \
	DB_NAME=$${input:-$(DB_NAME)}; \
	TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	mkdir -p backups; \
	echo "🔄 Backing up database '$$DB_NAME'..."; \
	docker exec -it $(POSTGRES_CONTAINER) pg_dump -U $(DB_USER) $$DB_NAME > backups/backup_$$DB_NAME_$$TIMESTAMP.sql; \
	echo "✅ Backup completed: backups/backup_$$DB_NAME_$$TIMESTAMP.sql"

.PHONY: backup-db

# Restore de la base de datos
restore-db:
	@read -p "-----[INPUT] Enter the database name to restore: " dbname; \
	read -p "-----[INPUT] Enter the backup file path: " backupfile; \
	echo "🔄 Restoring database '$$dbname' from '$$backupfile'..."; \
	docker exec -i $(POSTGRES_CONTAINER) psql -U $(DB_USER) $$dbname < $$backupfile; \
	echo "✅ Restore completed"

.PHONY: restore-db

# Mostrar estado de los contenedores
status:
	docker-compose ps

.PHONY: status

# Limpiar contenedores y volúmenes (¡CUIDADO! Esto elimina datos)
clean:
	docker-compose down -v
	@echo "✅ All containers and volumes removed"

.PHONY: clean

# Instalar dependencias de un módulo
install-dependencies:
	@read -p "-----[INPUT] Enter the module path (e.g., /mnt/extra-addons/my_module): " modulepath; \
	echo "🔄 Installing Python dependencies for module..."; \
	docker exec -it $(ODOO_CONTAINER) bash -c "if [ -f \"$$modulepath/requirements.txt\" ]; then pip3 install -r \"$$modulepath/requirements.txt\"; else echo \"No requirements.txt found\"; fi"; \
	echo "✅ Dependencies installed"

.PHONY: install-dependencies