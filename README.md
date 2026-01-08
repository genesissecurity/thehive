# TheHive + Cassandra + Nginx (HTTPS)

Stack Docker com:

- TheHive 4
- Cassandra
- Nginx fazendo proxy reverso + HTTPS com certificado autoassinado

Este README foi feito para facilitar a primeira instalação e os próximos deploys.

## ✅ Pré-requisitos

- Linux (testado em Ubuntu 22.04+)
- Docker
- Docker Compose v2 (`docker compose`)
- Git

Confirme:

```
docker --version
docker compose version
```

## 📥 1. Baixar o Script de Instalação

```
wget https://packages.genesissecurity.com.br/thehive/thehive.sh
chmod +x thehive.sh
./thehive.sh
```

## 🌍 2. Acessar

TheHive:
```
http://SEU_SERVIDOR:9000
```

Via Nginx:
```
https://thehive.yourdomain.com
```

## 🛠️ 3. Troubleshooting

### Erro de index
```
rm -rf vol/thehive/index
chown -R 1000:1000 vol/thehive
chmod -R 775 vol/thehive
docker compose restart thehive
```











