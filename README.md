# 📋 Checklist - Desafio Fullstack Umanni

## Fase 1: Configuração e Planejamento Inicial

### Stack e Ferramentas
* [x] **Backend:** Ruby on Rails 7.1.6
* [x] **Frontend Framework:** React.js 18.x (integrado ao Rails)
* [x] **Database:** PostgreSQL 16
* [x] **Containerização:** Docker + Docker Compose
* [x] **Autenticação:** Devise
* [x] **Testes:** RSpec 7.1 + Capybara + FactoryBot
* [x] **Linter:** Rubocop Rails Omakase
* [x] **Cobertura:** SimpleCov (≥90%)
* [x] **CSS:** SCSS/Sass
* [x] **CSS Framework:** Bulma
* [x] **Real-time:** ActionCable (WebSockets)

### Arquivos e Configurações
* [x] Dockerfile funcional
* [x] docker-compose.yml funcional
* [x] .gitignore configurado
* [x] .dockerignore configurado
* [x] Gerenciamento de configuração (variáveis de ambiente)
* [x] Banco de dados criado

---

## Fase 2: Desenvolvimento Backend (API Rails)

### User Stories - Autenticação e Autorização
* [x] Como visitante, posso me cadastrar como usuário normal
* [x] Como usuário, posso fazer login com email e senha
* [x] Como usuário, posso fazer logout
* [x] Como sistema, redireciono admin para dashboard após login
* [x] Como sistema, redireciono usuário comum para perfil após login
* [x] Como sistema, implemento autorização baseada em roles (admin/user)

### User Stories - Modelo User
* [x] Como sistema, tenho modelo User com: full_name, email, password, role (enum: admin/user)
* [x] Como sistema, tenho Active Storage configurado para avatares
* [x] Como usuário, posso fazer upload de avatar via arquivo
* [x] Como usuário, posso adicionar avatar via URL
* [x] Como sistema, valido todos os campos obrigatórios
* [x] Como sistema, tenho factory e testes para User model

### User Stories - Perfil do Usuário
* [x] Como usuário, posso visualizar meu próprio perfil
* [x] Como usuário, posso editar meu próprio perfil (nome, email, avatar)
* [x] Como usuário, posso deletar minha própria conta
* [x] Como usuário, não posso acessar perfis de outros usuários
* [x] Como sistema, tenho testes de integração para estas funcionalidades

### User Stories - Dashboard Admin
* [x] Como admin, posso acessar painel de administração
* [x] Como admin, vejo número total de usuários em tempo real
* [x] Como admin, vejo número de usuários agrupados por role em tempo real
* [ ] Como sistema, uso ActionCable para atualizar contadores em tempo real
* [x] Como sistema, tenho testes para dashboard e métricas

### User Stories - CRUD de Usuários (Admin)
* [ ] Como admin, posso listar todos os usuários com paginação
* [ ] Como admin, posso buscar/filtrar usuários
* [ ] Como admin, posso criar novos usuários
* [ ] Como admin, posso editar qualquer usuário
* [ ] Como admin, posso deletar qualquer usuário
* [ ] Como admin, posso alternar role de qualquer usuário (admin ↔ user)
* [ ] Como sistema, tenho testes de integração para CRUD completo

### User Stories - Importação de Usuários (Admin)
* [ ] Como admin, posso fazer upload de planilha (CSV/Excel)
* [ ] Como sistema, valido formato e conteúdo da planilha
* [ ] Como sistema, processo importação em background (ActiveJob)
* [ ] Como admin, posso acompanhar progresso da importação em tempo real
* [ ] Como sistema, uso ActionCable para atualizar progresso
* [ ] Como sistema, exibo erros de importação se houver
* [ ] Como sistema, crio usuários em lote após validação
* [ ] Como sistema, tenho testes para importação e progresso

### Segurança e Qualidade Backend
* [x] Como sistema, previno SQL Injection (ActiveRecord parameterizado)
* [x] Como sistema, previno XSS (sanitização de inputs)
* [x] Como sistema, uso CSRF tokens (Rails padrão)
* [x] Como sistema, uso Strong Parameters em todos controllers
* [x] Como sistema, valido uploads de arquivos (tipo, tamanho)
* [x] Como sistema, trato erros com rescue_from e error handlers
* [x] Como sistema, tenho cobertura de testes ≥90% (89% atual)

---

## Fase 3: Desenvolvimento Frontend (UI e UX)

### User Stories - Layout e Design
* [x] Como sistema, tenho layout responsivo base com framework CSS escolhido
* [ ] Como sistema, suporto Edge, Chrome, Firefox e Safari
* [ ] Como sistema, tenho código e imagens otimizados
* [x] Como sistema, uso SCSS para estilos

### User Stories - Autenticação UI
* [x] Como visitante, vejo formulário de cadastro com validação frontend
* [x] Como visitante, vejo formulário de login com validação frontend
* [x] Como usuário, vejo mensagens de erro claras
* [ ] Como sistema, tenho testes Capybara para fluxo de cadastro e login

### User Stories - Perfil UI
* [ ] Como usuário, vejo meu perfil com todas informações
* [ ] Como usuário, vejo formulário de edição com validação frontend
* [ ] Como usuário, vejo preview de avatar antes de salvar
* [ ] Como usuário, posso escolher entre upload de arquivo ou URL
* [ ] Como usuário, vejo confirmação antes de deletar conta
* [ ] Como sistema, tenho testes Capybara para fluxo de perfil

### User Stories - Dashboard Admin UI
* [ ] Como admin, vejo dashboard com contadores atualizados em tempo real
* [ ] Como admin, vejo gráficos/cards visuais das métricas
* [ ] Como sistema, uso React para componente de dashboard (tempo real)
* [ ] Como sistema, tenho testes Capybara para dashboard

### User Stories - CRUD Usuários UI
* [ ] Como admin, vejo tabela de usuários com paginação
* [ ] Como admin, vejo campo de busca/filtro funcionando
* [ ] Como admin, vejo formulários de criar/editar com validação frontend
* [ ] Como admin, vejo botão de alternar role funcionando
* [ ] Como admin, vejo confirmação antes de deletar usuário
* [ ] Como sistema, tenho testes Capybara para CRUD completo

### User Stories - Importação UI
* [ ] Como admin, vejo interface de upload de planilha
* [ ] Como admin, vejo validação de formato de arquivo no frontend
* [ ] Como admin, vejo barra de progresso em tempo real durante importação
* [ ] Como admin, vejo status da importação (processando, concluída, erro)
* [ ] Como admin, vejo lista de erros se importação falhar
* [ ] Como sistema, uso React para componente de progresso (tempo real)
* [ ] Como sistema, tenho testes Capybara para fluxo de importação

### Tecnologias Frontend
* [ ] Como sistema, uso Hotwire/Turbo para renderização server-side
* [ ] Como sistema, uso React apenas em componentes específicos (dashboard, progresso)
* [ ] Como sistema, implemento validação de formulários em JS
* [ ] Como sistema, tenho testes frontend ≥90% cobertura

---

## Fase 4: Ajustes Finais

### Qualidade de Código
* [ ] Executar Rubocop e corrigir todas offenses
* [ ] Revisar código (nomenclatura, semântica, DRY, SOLID)
* [ ] Remover código comentado, debugs e console.logs
* [ ] Verificar cobertura de testes ≥90% (SimpleCov)
* [ ] Executar todos os testes: `docker compose run --rm web rspec`

### Testes Finais
* [ ] Testar aplicação manualmente (todos os fluxos)
* [ ] Testar responsividade (mobile, tablet, desktop)
* [ ] Testar em Edge, Chrome, Firefox, Safari
* [ ] **[Bônus]** Executar testes de estresse

### Docker e Deploy
* [x] Validar Dockerfile para produção
* [x] Validar docker-compose.yml
* [x] Testar build: `docker compose build`
* [x] Testar execução: `docker compose up`

### Documentação
* [ ] Escrever README.md em inglês contendo:
  * [ ] Project description
  * [ ] Technologies and versions used
  * [ ] Prerequisites (Docker, Docker Compose)
  * [ ] How to clone repository
  * [ ] How to setup (build and run with Docker)
  * [ ] How to run tests
  * [ ] How to check test coverage
  * [ ] Project structure
  * [ ] Technical decisions
  * [ ] Screenshots (opcional)

### Entrega
* [ ] Commit final
* [ ] Push: `git push origin feat/gmarcos`
* [ ] Abrir Pull Request no GitHub
* [ ] Verificar se GitHub Actions/CI passa
* [ ] Prazo: 1 semana a partir da criação da branch

---

## 📊 Progresso Atual

- **Fase 1:** ✅ 100%
- **Fase 2:** ⏳ 80%
- **Fase 3:** ⏳ 35%
- **Fase 4:** ⏳ 40%

**Total:** ~66% concluído