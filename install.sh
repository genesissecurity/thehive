#!/usr/bin/env bash
set -e

INSTALL_DIR="/home/ubuntu/thehive"
REPO_URL="https://github.com/genesissecurity/thehive"

log(){ echo -e "\n🔹 $1"; }
die(){ echo -e "\n❌ $1"; exit 1; }

echo "==============================================="
echo "        INSTALADOR AUTOMÁTICO THEHIVE"
echo "==============================================="

read -p "Digite o domínio (ex: thehive.seudominio.com): " DOMAIN
[ -z "$DOMAIN" ] && die "Domínio não informado."

log "Diretório raiz: $INSTALL_DIR"
log "Domínio: $DOMAIN"

# 1. Dependências
log "Verificando dependências..."
for cmd in git docker openssl; do
  command -v $cmd >/dev/null || die "Dependência ausente: $cmd"
done
docker compose version >/dev/null || die "Docker Compose v2 não encontrado"

# 2. Clone
if [ ! -d "$INSTALL_DIR" ]; then
  log "Clonando repositório..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR" || die "Falha ao acessar $INSTALL_DIR"

# 3. Network proxy
log "Garantindo Docker network proxy..."
docker network inspect proxy >/dev/null 2>&1 || docker network create proxy

# 4. Estrutura de volumes (EXATAMENTE como no compose)
log "Criando estrutura de volumes..."
mkdir -p \
  vol/cassandra/data \
  vol/nginx \
  vol/ssl \
  vol/thehive/{data,index,files,logs}

# 5. SSL
if [ ! -f vol/ssl/nginx-selfsigned.key ]; then
  log "Gerando certificados SSL..."
  openssl genrsa -out vol/ssl/nginx-selfsigned.key 2048
  openssl req -new -x509 \
    -key vol/ssl/nginx-selfsigned.key \
    -out vol/ssl/nginx-selfsigned.crt \
    -days 365 \
    -subj "/C=BR/ST=SP/L=SP/O=GenesisSecurity/OU=SOC/CN=$DOMAIN"
fi

# 6. Config Nginx (caminho de certificado correto)
log "Configurando Nginx..."
cat > vol/nginx/thehive.conf <<EOF
server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/nginx-selfsigned.key;

    location / {
        proxy_pass http://thehive:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
EOF

# 7. Permissões (IGUAIS AO README)
log "Ajustando permissões..."

log "THEHIVE"
chown -R 1000:1000 vol/thehive
chmod -R 775 vol/thehive

log "CASSANDRA"
chown -R 999:999 vol/cassandra
chmod -R 700 vol/cassandra

log "NGINX"
chown -R 33:33 vol/nginx
chmod -R 755 vol/nginx

log "SSL"
chown -R 33:33 vol/ssl
chmod 600 vol/ssl/*.key
chmod 644 vol/ssl/*.crt

# 8. Subir ambiente
log "Subindo stack Docker..."
docker compose up -d

echo "==============================================="
echo "✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO"
echo "🌐 HTTPS: https://$DOMAIN"
echo "🌍 HTTP:  http://SEU_SERVIDOR:9000"
echo "==============================================="
