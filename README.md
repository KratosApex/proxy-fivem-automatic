# Proxy FiveM Automatic Installer

🚀 Script simples e automatizado para configurar uma **proxy com cache** usando **Nginx** para servidores **FiveM**.

Ideal para reduzir uso de banda, melhorar performance e proteger o IP real do seu servidor.

---

## 📦 Requisitos

- Ubuntu 20.04 ou superior
- Domínio apontando para o IP da proxy
- Permissão de root

---

## 🔧 Instalação

Clone o repositório e torne o script executável:

```bash
git clone https://github.com/KratosApex/proxy-fivem-automatic.git
cd proxy-fivem-automatic
chmod +x criar_proxy.sh
sudo ./criar_proxy.sh
```

---

## 📋 O que o script faz

1. Solicita o domínio, IP e porta do seu servidor FiveM
2. Cria cache com Nginx para `/`
3. Instala certificado SSL com Let's Encrypt (opcional)
4. Gera automaticamente uma chave `adhesive_cdnKey`
5. Exibe instruções para adicionar ao seu `server.cfg`

---

## 🌐 Múltiplas Proxies no Mesmo Servidor

Sim, é possível rodar **várias proxies com diferentes domínios** no mesmo IP. Basta rodar o script novamente com um novo domínio e IP de destino.

Cada proxy escutará em sua própria entrada `server_name`, sem conflito.

---

## 📄 Exemplo de uso no `server.cfg`

```cfg
sv_downloadurl "https://seudominio.com"
set adhesive_cdnKey "chave_gerada_pelo_script"
```

---

## 🧪 Em breve

- [ ] Interface de menu interativo para listar, criar e remover proxies
- [ ] Suporte a domínios wildcard (`*.seudominio.com`)
- [ ] GitHub Actions para validação automática
- [ ] Versão em inglês

---

## 🔗 Criado por

Projeto desenvolvido por [BrasilFiveMHost.com.br](https://www.brasilfivemhost.com.br) para a comunidade.

Repositório oficial: [github.com/KratosApex/proxy-fivem-automatic](https://github.com/KratosApex/proxy-fivem-automatic)

---

Se quiser posso também gerar um badge bonito com status (tipo versão ou build), traduzir para inglês ou criar GIF demonstrando. Só avisar!
