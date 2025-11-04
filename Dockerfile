# Imagem base
FROM ruby:3.3

# Instala dependências do sistema
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Define diretório de trabalho
WORKDIR /app

# Copia arquivos
COPY Gemfile* ./
RUN bundle install

COPY . .

# Expõe a porta
EXPOSE 3000

# Comando padrão
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"]
