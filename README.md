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

## 📥 1. Clonar o repositório

```
git clone https://github.com/genesissecurity/thehive
cd thehive
```

## 🌐 2. Criar a Docker network `proxy`

```
docker network create proxy
```

## 📂 3. Garantir a estrutura de volumes

```
mkdir -p vol/cassandra vol/elasticsearch vol/nginx vol/ssl vol/thehive
```

## 🔐 4. Criar os certificados autoassinados (SSL)

### 4.1 Chave privada

```
openssl genrsa -out vol/ssl/nginx-selfsigned.key 2048
```

### 4.2 Certificado

```
openssl req -new -x509   -key vol/ssl/nginx-selfsigned.key   -out vol/ssl/nginx-selfsigned.crt   -days 365
```

## 🔑 5 Configurar `thehive.conf`

```
cd vol/nginx
Edite os arquivos thehive.conf
Ajuste server_name thehive.yourdomain.com;
```

## 🧾 6. Ajustar permissões

### THEHIVE
```
chown -R 1000:1000 vol/thehive
chmod -R 775 vol/thehive
```

### CASSANDRA
```
chown -R 999:999 vol/cassandra
chmod -R 700 vol/cassandra
```

### NGINX
```
chown -R 33:33 vol/nginx
chmod -R 755 vol/nginx
```

### SSL
```
chown -R 33:33 vol/ssl
chmod 600 vol/ssl/*.key
chmod 644 vol/ssl/*.crt
```

## 🚀 7. Subir o ambiente

```
docker compose up -d
```

## 🌍 8. Acessar

TheHive:
```
http://SEU_SERVIDOR:9000
```

Via Nginx:
```
https://thehive.yourdomain.com
```

## ♻️ 9. Atualizar API Key futuramente

```
docker compose restart thehive
```

## 🛠️ 10. Troubleshooting

### TheHive reiniciando
→ `.env` inválido

### Erro de index
```
rm -rf vol/thehive/index
chown -R 1000:1000 vol/thehive
chmod -R 775 vol/thehive
docker compose restart thehive
```





