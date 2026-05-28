# Routine - Gerenciador de Rotina Pessoal

## Descrição do Aplicativo
O **Routine** é um aplicativo completo de produtividade e organização pessoal desenvolvido em Flutter. Ele centraliza as quatro áreas mais importantes do dia a dia do usuário: gestão de tarefas, controle financeiro, rotina de treinos e acompanhamento de estudos. O sistema conta com uma interface moderna, navegação intuitiva via menu lateral (Drawer) e armazenamento em nuvem seguro.

## Funcionalidades Principais
- **Autenticação e Segurança:** - Login e Cadastro nativos.
    - Bloqueio de rotas não autenticadas.
    - Separação rigorosa de dados por usuário (cada usuário só visualiza seus próprios registros).
- **Minhas Tarefas (Agenda):**
    - Adição de compromissos com data de vencimento.
    - Categorização colorida (Trabalho, Faculdade, Finanças, etc).
    - Checkbox para marcar conclusão e opção de editar/excluir.
- **Dashboard Financeiro:**
    - Resumo de Receitas e Despesas do mês.
    - Controle de carteira de investimentos (FIIs e Renda Fixa) com barras de progresso visuais.
    - Histórico de últimas movimentações dinâmico.
- **Rotina de Treinos:**
    - Cartões interativos separados por grupos musculares (Peito, Costas, Pernas, etc).
    - Cadastro detalhado de exercícios contendo número de séries, repetições e carga (kg).
- **Estudos e Projetos:**
    - Painel de acompanhamento de cursos, semestres e projetos.
    - Controle deslizante interativo para atualizar o percentual de progresso (0% a 100%).

## Tecnologias Utilizadas
- **Frontend:** Flutter (Dart)
- **Backend/BaaS:** Supabase
- **Autenticação:** Supabase Auth (E-mail e Senha)
- **Banco de Dados:** PostgreSQL (Tabelas: `tasks`, `transactions`, `exercises`, `studies`)

## Segurança e Persistência de Dados
O aplicativo utiliza o **Row Level Security (RLS)** do PostgreSQL gerenciado pelo Supabase. Quatro políticas rigorosas de segurança (SELECT, INSERT, UPDATE, DELETE) foram aplicadas em todas as tabelas do sistema, garantindo que a cláusula `auth.uid() = user_id` seja sempre respeitada, prevenindo o vazamento de dados entre contas diferentes.

## Estrutura do Projeto (Arquitetura)
O código segue o padrão de separação de responsabilidades para facilitar a manutenção e escalabilidade:
- `/models`: Representação em classes dos dados do banco (ex: `finance_transaction.dart`).
- `/services`: Comunicação com a API do Supabase (Autenticação e Banco de Dados).
- `/screens`: Telas e fluxo de interface (Login, Cadastro, Home e as 4 abas do Dashboard).
- `/widgets`: Componentes visuais isolados e reutilizáveis (ex: campos de formulário customizados).

## Instruções para Executar
1. Clone este repositório.
2. Certifique-se de possuir o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
3. No terminal, na raiz do projeto, instale as dependências:
   ```bash
   flutter pub get