#!/bin/bash

PROXY_LIST="/etc/nginx/sites-available"
CACHE_DIR_BASE="/var/www"
NGINX_ENABLED="/etc/nginx/sites-enabled"

function gerar_cdn_key() {
  openssl rand -hex 16
}

function listar_proxies() {
  echo ""
  echo "📋 Proxies configuradas:"
  echo "-------------------------"
  for conf in $PROXY_LIST/fivem-proxy-*; do
    domain=$(grep -i 'server_name' "$conf" | awk '{print $2}' | sed 's/;//')
    echo "• $domain"
  done
  echo "-------------------------"
}

function criar_proxy() {
  read -p "🌐 Informe o domínio da nova proxy (ex: proxy.meuserver.com): " SERVER_DOMAIN
  read -p "🖥️  IP do servidor FiveM: " SERVER_IP
  read -p "🔌 Porta do servidor FiveM (padrão 30120): " SERVER_PORT
  read -p "🔒 Deseja ativar HTTPS (SSL) com Let's Encrypt? [s/N]: " USE_SSL

  if [ -z "$SERVER_PORT" ]; then
    SERVER_PORT=30120
  fi

  CDN_KEY=$(gerar_cdn_key)
  FIVEM_ORIGIN="http://$SERVER_IP:$SERVER_PORT"
  CACHE_DIR="$CACHE_DIR_BASE/fivem-cache-$SERVER_DOMAIN"
  NGINX_CONF="$PROXY_LIST/fivem-proxy-$SERVER_DOMAIN"

  echo ">> Criando diretório de cache..."
  sudo mkdir -p "$CACHE_DIR"
  sudo chown -R www-data:www-data "$CACHE_DIR"

  echo ">> Gerando configuração Nginx para $SERVER_DOMAIN..."
  sudo tee "$NGINX_CONF" > /dev/null <<EOL
proxy_cache_path $CACHE_DIR levels=1:2 keys_zone=fivem_cache_$SERVER_DOMAIN:10m max_size=1g inactive=60m use_temp_path=off;

server {
    listen 80;
    server_name $SERVER_DOMAIN;

    access_log /var/log/nginx/fivem_access_$SERVER_DOMAIN.log;
    error_log /var/log/nginx/fivem_error_$SERVER_DOMAIN.log;

    location / {
        proxy_pass $FIVEM_ORIGIN;
        proxy_cache fivem_cache_$SERVER_DOMAIN;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        add_header X-Cache-Status \$upstream_cache_status;
    }
}
EOL

  sudo ln -sf "$NGINX_CONF" "$NGINX_ENABLED/"
  sudo nginx -t && sudo systemctl reload nginx

  if [[ "$USE_SSL" =~ ^[sS]$ ]]; then
    echo ">> Instalando certificado SSL com Certbot..."
    sudo apt install -y certbot python3-certbot-nginx
    sudo certbot --nginx -d "$SERVER_DOMAIN" --non-interactive --agree-tos -m admin@$SERVER_DOMAIN --redirect

    if [ $? -eq 0 ]; then
      PROTO="https"
      echo ""
      echo "✅ Proxy HTTPS criada com sucesso para $SERVER_DOMAIN!"
    else
      echo "⚠️ Falha ao instalar SSL. Proxy será acessada via HTTP."
      PROTO="http"
    fi
  else
    PROTO="http"
    echo "✅ Proxy HTTP criada com sucesso para $SERVER_DOMAIN!"
  fi

  echo ""
  echo "➕ Adicione ao seu server.cfg:"
  echo "   sv_downloadurl \"$PROTO://$SERVER_DOMAIN\""
  echo "   set adhesive_cdnKey \"$CDN_KEY\""
  echo ""
}

function menu_principal() {
  while true; do
    echo ""
    echo "=============================="
    echo "     Gerenciador de Proxy FiveM"
    echo "=============================="
    echo "1. Listar proxies configuradas"
    echo "2. Adicionar nova proxy"
    echo "3. Sair"
    echo "=============================="
    read -p "Escolha uma opção [1-3]: " op

    case $op in
      1) listar_proxies ;;
      2) criar_proxy ;;
      3) echo "Saindo..."; break ;;
      *) echo "❌ Opção inválida!" ;;
    esac
  done
}

# Executa o menu
menu_principal
