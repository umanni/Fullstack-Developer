FROM ruby:3.3.0

# Instalar dependências do sistema
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    npm \
    postgresql-client \
    libvips \
    && rm -rf /var/lib/apt/lists/*

# Instalar Yarn
RUN npm install -g yarn

# Configurar diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY Gemfile Gemfile.lock package.json yarn.lock* ./

# Instalar gems e dependências JS
RUN bundle install && \
    yarn install --check-files

# Copiar o restante da aplicação
COPY . .

# Expor porta
EXPOSE 3000

# Comando padrão
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]