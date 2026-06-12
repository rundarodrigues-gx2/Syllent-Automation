# Plano de Testes — Connect Syllent

Plano de testes E2E mobile do app **Connect Syllent** automatizado com [Maestro](https://docs.maestro.dev).

| Item | Valor |
|------|-------|
| App | Connect Syllent (React Native / base Tuya) |
| `APP_ID` (Android) | `com.syllent.connect` |
| Plataformas | Android (emulador/dispositivo) · iOS (somente macOS) |
| Idiomas | Português · English · Español · Français |
| Execução | `maestro test --env APP_ID=com.syllent.connect .maestro` |

## Convenções

- **Status:** ✅ verde no emulador · 🟡 WIP (bloqueio externo) · ⬜ não implementado.
- **Tags:** `smoke`, `regression`, `login`, `signup`, `negativo`, `navegacao`, `i18n`,
  `autenticado`, `dashboard`, `perfil`, `automacoes`, `adesao`, `escrita`, `logout`,
  `android`, `ios`, `wip`.
- **Autenticados:** exigem sessão logada. O login real usa **2FA por e-mail**
  ("Device authorization"), não automatizável headless — autorize o dispositivo
  uma vez e rode os flows `autenticado` (abrem o app sem `clearState`).
- **`escrita`:** criam dados reais na conta (homes/rooms de teste).

---

## 1. Autenticação e acesso (não-autenticado)

### CT-01 — Abertura do app (smoke)
- **Arquivo:** `flows/shared/01_launch_smoke.yaml` · **Tags:** smoke · **Status:** ✅
- **Passos:** abrir o app com estado limpo → dispensar os 3 diálogos iniciais
  (compatibilidade 16KB, otimização de bateria, aviso "testing only").
- **Resultado esperado:** a tela de Login ("Sign in to your account") é exibida.

### CT-02 — Elementos da tela de Login
- **Arquivo:** `02_login_elementos.yaml` · **Tags:** smoke, login · **Status:** ✅
- **Passos:** abrir o app → ir para o Login.
- **Resultado esperado:** estão visíveis Email, Password, Remember email,
  Forgot your password?, Sign in, Don't have an account?, Sign up.

### CT-03 — Login com credenciais inválidas
- **Arquivo:** `03_login_invalido.yaml` · **Tags:** regression, login, negativo · **Status:** ✅
- **Passos:** informar e-mail e senha inválidos → tocar em "Sign in".
- **Resultado esperado:** o app permanece na tela de Login (não autentica).

### CT-04 — Mostrar/ocultar senha
- **Arquivo:** `04_mostrar_senha.yaml` · **Tags:** regression, login · **Status:** ✅
- **Passos:** digitar senha no campo correto → acionar o ícone "Show password".
- **Resultado esperado:** a interação ocorre sem erro e o app permanece no Login.
  *(Obs.: RN não expõe a senha em texto claro ao automation — evidência por screenshot.)*

### CT-05 — Lembrar e-mail (interação)
- **Arquivo:** `05_lembrar_email.yaml` · **Tags:** regression, login · **Status:** ✅
- **Passos:** digitar e-mail → marcar "Remember email".
- **Resultado esperado:** controle alternado sem erro.
  *(Obs.: a persistência real só ocorre após login bem-sucedido — fora de escopo headless.)*

### CT-06 — Navegação Login ↔ Cadastro
- **Arquivo:** `06_navegacao_login_signup.yaml` · **Tags:** regression, navegacao · **Status:** ✅
- **Passos:** Login → "Sign up" → "Log in".
- **Resultado esperado:** abre "Create your account" e retorna a "Sign in to your account".

### CT-07 — Elementos da tela de Cadastro
- **Arquivo:** `07_signup_elementos.yaml` · **Tags:** smoke, signup · **Status:** ✅
- **Passos:** ir para a tela de cadastro.
- **Resultado esperado:** visíveis "Create your account", verificação por e-mail,
  "Enter the 6-digit code", Personal details, "Already have an account?", Log in.

### CT-08 — Cadastro com e-mail inválido
- **Arquivo:** `08_signup_email_invalido.yaml` · **Tags:** regression, signup, negativo · **Status:** ✅
- **Passos:** informar e-mail malformado → "Send code".
- **Resultado esperado:** permanece no cadastro (não avança para o código).

### CT-09 — Recuperação de senha
- **Arquivo:** `09_recuperar_senha.yaml` · **Tags:** regression, login · **Status:** ✅
- **Passos:** Login → "Forgot your password?" → informar e-mail.
- **Resultado esperado:** tela "Recover password" com o botão "Send code".

### CT-10 — Idioma na tela de Login (PT/EN/ES/FR)
- **Arquivo:** `10_troca_idioma.yaml` · **Tags:** regression, i18n · **Status:** ✅
- **Passos:** alternar idioma pelas bandeiras (Português, Español, Français, English).
- **Resultado esperado:** título e textos traduzem em cada idioma
  (ex.: "Entre na sua conta", "Inicia sesión en tu cuenta", "Connectez-vous à votre compte").

### CT-11 — Android: botão voltar nativo
- **Arquivo:** `flows/android/android_voltar.yaml` · **Tags:** android, regression · **Status:** ✅
- **Passos:** Login → "Forgot your password?" → botão físico Back.
- **Resultado esperado:** retorna à tela de Login.

### CT-12 — iOS: gesto swipe back
- **Arquivo:** `flows/ios/ios_swipe_back.yaml` · **Tags:** ios, regression · **Status:** ⬜ (só macOS)
- **Passos:** Login → "Forgot your password?" → swipe da borda esquerda.
- **Resultado esperado:** retorna à tela de Login.

---

## 2. Área autenticada

### CT-13 — Login autenticado (E2E)
- **Arquivo:** `11_login_autenticado.yaml` · **Tags:** wip, login, autenticado · **Status:** 🟡
- **Passos:** informar credenciais → Sign in → concluir **Device authorization** (2FA por e-mail).
- **Resultado esperado:** acesso à área autenticada.
- **Bloqueio:** código 2FA enviado por e-mail (não headless).

### CT-14 — Elementos da Home
- **Arquivo:** `12_home_elementos.yaml` · **Tags:** autenticado, smoke · **Status:** ✅
- **Passos:** abrir o app logado.
- **Resultado esperado:** barra de navegação inferior visível (Home, Dashboard, Devices, Account).

### CT-15 — Navegação entre abas
- **Arquivo:** `13_navegacao_tabs.yaml` · **Tags:** autenticado, navegacao · **Status:** ✅
- **Passos:** Account → Devices → Dashboard → Home.
- **Resultado esperado:** Account mostra "Sign out"; Devices mostra "AUTOMATIONS"; Home mostra "Dashboard".

### CT-16 — Elementos da Conta
- **Arquivo:** `14_conta_elementos.yaml` · **Tags:** autenticado, regression · **Status:** ✅
- **Passos:** abrir a aba Account.
- **Resultado esperado:** visíveis Personal details, App settings, Help center, Terms of Use,
  Sign out e o e-mail do usuário.

### CT-17 — Logout
- **Arquivo:** `15_logout.yaml` · **Tags:** autenticado, logout · **Status:** ✅
- **Passos:** Account → "Sign out".
- **Resultado esperado:** retorna à tela de Login. *(Encerra a sessão — rodar isolado.)*

### CT-18 — Automações e Cenas (estrutura)
- **Arquivo:** `16_automacoes_cenas.yaml` · **Tags:** autenticado, automacoes · **Status:** ✅
- **Passos:** abrir a aba Devices → abrir a sub-aba Automation.
- **Resultado esperado:** visíveis AUTOMATIONS, Scenes, Automation, Tap-to-Run; aba Automation
  com estado vazio ("No item created").

### CT-19 — Adesão de Home
- **Arquivo:** `17_adesao_home.yaml` · **Tags:** autenticado, adesao, escrita · **Status:** ✅
- **Passos:** **+** → New home → informar nome → Save.
- **Resultado esperado:** confirmação "Home added!" (opção de adicionar cômodo).

### CT-20 — Adesão de Room (pelo + da Home)
- **Arquivo:** `18_adesao_room.yaml` · **Tags:** autenticado, adesao, escrita · **Status:** ✅
- **Passos:** Home → **+** → New room → informar nome → Save.
- **Resultado esperado:** cômodo criado (lista "Room(s)").

### CT-21 — Adesão de Device (catálogo)
- **Arquivo:** `19_adesao_device.yaml` · **Tags:** autenticado, adesao · **Status:** ✅
- **Passos:** **+** → New device.
- **Resultado esperado:** tela "Add Device" com "Add Manually" e categorias (Lighting, Sensors…).
- **Obs.:** pareamento real exige hardware.

### CT-22 — Idioma no app inteiro (PT/EN/ES/FR)
- **Arquivo:** `20_idioma_app.yaml` · **Tags:** autenticado, i18n, regression · **Status:** ✅
- **Passos:** para cada idioma, trocar em *Account › App settings › App language* e navegar.
- **Resultado esperado:** traduzem **Perfil** (Sign out / Personal details), **Home** (Edit),
  **Automações** (header), **Cenas**, **Automação** e **Ambientes** (Select a room).

### CT-23 — Add data (dashboard)
- **Arquivo:** `21_add_data_home.yaml` · **Tags:** autenticado, dashboard · **Status:** ✅
- **Passos:** Home → "+ Add data".
- **Resultado esperado:** seletor "Select device" com estado vazio
  ("No device paired in this pool.").

### CT-24 — Editar dashboard
- **Arquivo:** `22_editar_dashboard.yaml` · **Tags:** autenticado, dashboard · **Status:** ✅
- **Passos:** Home → "Edit" → "Save".
- **Resultado esperado:** modo de edição (Save, "Visible on Home", Reorder/Hide widget) e
  retorno ao estado normal ("Edit").

### CT-25 — Editar foto de perfil
- **Arquivo:** `23_editar_foto_perfil.yaml` · **Tags:** autenticado, perfil · **Status:** ✅
- **Passos:** Account → Personal details → "Edit photo".
- **Resultado esperado:** opções "Take photo", "Choose from gallery", "Remove current photo".

### CT-26 — Adesão de Room (tela de cômodos / ícone de porta)
- **Arquivo:** `24_adesao_room_porta.yaml` · **Tags:** autenticado, adesao, escrita · **Status:** ✅
- **Passos:** ícone de porta (2º item da barra) → tela "Room(s)" → "Add room" → informar nome → Save.
- **Resultado esperado:** cômodo criado, retornando à lista "Room(s)".

---

## Cobertura

| Área | Cobertura |
|------|-----------|
| Autenticação / acesso | Login (elementos/inválido), cadastro, recuperação, logout |
| Navegação | Login↔Signup, abas, back Android, swipe iOS |
| Home / Dashboard | Elementos, Add data, editar dashboard |
| Conta / Perfil | Itens da conta, foto de perfil |
| Adesão | Home, Room (pelo + e pela tela de cômodos), Device (catálogo) |
| Automações / Cenas | Estrutura da aba Devices |
| i18n | Login + app inteiro (4 idiomas) |

## Lacunas conhecidas

**Bloqueadas por fator externo**
- Login/cadastro/recuperação **E2E** (código 2FA/e-mail).
- Pareamento real de **device** (hardware BLE/Wi-Fi/Zigbee).
- Execução em **iOS** (macOS).

**Automatizáveis (a fazer)**
- **Aba Pool:** equipamentos (Bombas, Filtros, Aquecedores, Controladores, Iluminação,
  Cloradores, Outros) e ações de "Add".
- **Cenas/Automações (ações reais):** criar/rodar cena, criar automação, "Configure" das
  cenas sugeridas.
- **App settings:** tema (System/Light/Dark), Two-step authentication, Biometrics.
- **Conta:** editar dados pessoais (nome/telefone), trocar senha, People management,
  Communication, Integrations, Backups, Social networks, Help center, Terms of Use.
- **Gestão de Home/Room:** editar/excluir home, trocar home ativa, editar/excluir room.
- **Casos negativos extras:** campos obrigatórios vazios, senha curta, formatos inválidos.

---

## 🐞 Achado de bug (i18n)

A **barra de navegação inferior** (Home / Dashboard / Devices / Account) **não traduz** —
permanece em inglês em PT/ES/FR, enquanto todo o restante do app traduz corretamente.
Provável causa: rótulos do tab navigator não passam pela função de i18n ou o navegador
não re-renderiza na troca de locale. Severidade baixa, porém muito visível.
