# This is a compose to use Docker with Odoo14, PostgreSQL and PgAdmin in Ubuntu/Linux
the content of the folder addons will be ignored by git, but the  folder don't 

Guía rápida Docker
1. Instalar Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

2. Instala Docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

3.Dar permisos necesarios
- Dar permisos a tu usuario para usar Docker sin sudo
sudo usermod -aG docker $USER
- Dar permisos a los directorios
chmod -R 755 .
- CERRAR COMPLETAMENTE LA TERMINAL y abrir una nueva 
- Verificar que funciona
docker run hello-world

4. Instalar Odoo 14, postgres y pgadmin
make docker up

5.Inicializa DB
make init-db

6. Pasos en pgAdmin:
Ve a http://localhost:8080
Login con: email: dayronpeeta@gmail.com, password: postgres
Add New Server → Connection:
Name: Odoo14-DB
Host: postgres
Port: 5432
Username: odoo14
Password: odoo14
  
7. Acceder a Odoo
URL: http://localhost:8114

Usuario: admin
Contraseña: admin

8. Reconstruir assets (si fallan)
docker exec -it odoo_14_odoo_1 odoo -d odoo14 --stop-after-init -u web
