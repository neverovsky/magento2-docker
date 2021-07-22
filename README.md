# Docker for Magento 2 project

includes:
- nginx
- php-fpm 7.4
- mssql-client/server (optional)
- mysql



steps:
- copy folder to project-home/_docker
- copy docker-compose.yml to project-home/
- run ```docker-compose up```
