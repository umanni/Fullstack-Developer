# 🚀 Sistema de Gerenciamento de Usuários

Um sistema completo de gerenciamento de usuários em Ruby on Rails com funcionalidades avançadas de autenticação, autorização baseada em roles e importação de usuários via CSV com processamento em background e atualizações em tempo real.

## ✨ Funcionalidades

### 🔐 **Autenticação e Autorização**
- ✅ Sistema completo de autenticação com **Devise**
- ✅ **Roles** hierárquicos (Admin, Manager, User)
- ✅ Controle de acesso granular por funcionalidade
- ✅ Rastreamento de login para auditoria
- ✅ Proteção contra ataques comuns (CSRF, XSS)

### 👥 **Gerenciamento de Usuários**
- ✅ **CRUD completo** para administradores
- ✅ **Perfil editável** pelos próprios usuários
- ✅ **Busca avançada** (nome, email, role, status)
- ✅ **Filtros dinâmicos** com paginação
- ✅ **Validações robustas** e feedback de erros

### 📊 **Dashboard Administrativo**
- ✅ **Métricas em tempo real** via WebSockets
- ✅ **Estatísticas do sistema** (usuários, roles, atividade)
- ✅ **Interface responsiva** com Bootstrap 5
- ✅ **Atualizações automáticas** sem refresh

### 📁 **Importação CSV**
- ✅ **Upload de arquivos** com validação
- ✅ **Processamento assíncrono** em background
- ✅ **Progress tracking** em tempo real
- ✅ **Relatórios de erro** detalhados
- ✅ **Histórico de importações** com status

## 🛠️ Tecnologias

### Backend
- **Ruby 3.2.0**
- **Rails 7.x**
- **SQLite** (desenvolvimento)
- **Devise** (autenticação)

### Frontend
- **Bootstrap 5** (UI Framework)
- **Stimulus** (JavaScript framework)
- **Turbo** (SPA-like experience)
- **Simple Form** (formulários)
- **Importmap** (ES6 modules)

### Ferramentas
- **Docker** (containerização)
- **Git** (controle de versão)
- **Rubocop** (linting)
- **Brakeman** (security scanning)

## 🚀 Instalação

### Setup Local

1. **Clone o repositório:**
```bash
git clone https://github.com/lucasleandro1/Fullstack-Developer.git
cd Fullstack-Developer
```
2. **Rode os comandos:**
```bash
cp .env.example .env
```
## Adicione sua master key no .env
```bash
docker compose build
docker compose up
```

5. **Acesse a aplicação:**
```
http://localhost:3000
```
6. **Entre com:**
```
admin@example.com
password123
```

## 📖 Como Usar

### 1. **Login no Sistema**
- Acesse `/users/sign_in`
- Use um dos usuários de teste ou registre-se

### 2. **Dashboard (Admin/Manager)**
- Visualize métricas em tempo real
- Monitore atividade do sistema
- Acesse relatórios

### 3. **Gerenciamento de Usuários (Admin)**
- **Listar:** Veja todos os usuários com filtros
- **Criar:** Adicione novos usuários manualmente
- **Editar:** Modifique informações e roles
- **Excluir:** Remove usuários do sistema

### 4. **Importação CSV (Admin)**
- Acesse "Importações" no menu
- Faça upload de arquivo CSV
- Acompanhe o progresso em tempo real
- Veja relatório de resultados

**Formato do CSV:**
```csv
first_name,last_name,email,role
João,Silva,joao@example.com,user
Maria,Santos,maria@example.com,manager
```

### 5. **Perfil do Usuário**
- Edite suas informações pessoais
- Altere senha
- Visualize histórico de login

⭐ **Se este projeto foi útil, considere dar uma estrela!**
