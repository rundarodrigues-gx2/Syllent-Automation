# Syllent Automation

Automação de testes E2E mobile (Android e iOS) do app **Connect Syllent** usando
[Maestro](https://docs.maestro.dev).

Os fluxos são escritos uma única vez em YAML e executados nas duas plataformas,
parametrizados por `APP_ID` e com comandos condicionais por plataforma quando necessário.

## Sobre o app sob teste

| Campo | Valor |
|-------|-------|
| Nome | **Connect Syllent** |
| `APP_ID` (Android) | `com.syllent.connect` |
| Stack | React Native (base Tuya Smart) |
| Idiomas | Português, English, Español, Français |

Particularidades que moldam os flows:

- **React Native:** quase não há `resource-id`. Os seletores usam **texto** e
  `accessibility label` (ex.: `tapOn: "Sign in"`). O campo de senha é a **2ª**
  ocorrência de `"Password"` (`index: 1`) — a 1ª é o rótulo.
- **Diálogos de primeiro launch:** aparecem 3 (compatibilidade 16KB → otimização de
  bateria → aviso "testing only"). O subflow [`dismiss_dialogs`](.maestro/subflows/dismiss_dialogs.yaml) os trata.
- **2FA por e-mail:** após o login, o app pede um código de 6 dígitos
  ("Device authorization") a cada novo dispositivo/estado limpo. Isso **não roda
  headless** — veja [Flows autenticados](#flows-autenticados).

## Pré-requisitos

- **Java JDK 17+** (obrigatório para o Maestro).
- **Maestro CLI 2.6+**.
- **Android:** Android SDK + um emulador ou dispositivo físico conectado (`adb devices`).
- **iOS:** **macOS** com Xcode e um simulador iOS em execução (Maestro só executa iOS em macOS).

### Instalação no macOS / Linux
```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

### Instalação no Windows
```powershell
# 1. Java 17 (via winget)
winget install --id Microsoft.OpenJDK.17 --silent --accept-package-agreements --accept-source-agreements

# 2. Baixar o Maestro e extrair em C:\maestro
Invoke-WebRequest "https://github.com/mobile-dev-inc/maestro/releases/latest/download/maestro.zip" -OutFile "$env:TEMP\maestro.zip"
Expand-Archive "$env:TEMP\maestro.zip" -DestinationPath "C:\maestro" -Force

# 3. Adicionar ao PATH do usuário (binário fica em C:\maestro\maestro\bin)
setx PATH "$env:PATH;C:\maestro\maestro\bin"
# Reabra o terminal após este passo.
```

Verifique a instalação:
```bash
maestro --version   # esperado: 2.6.0+
```

> Dica: defina `MAESTRO_CLI_NO_ANALYTICS=1` para silenciar o banner de analytics.

## Estrutura do projeto

```
.maestro/
├── config.yaml              # Workspace (flows, tags excluídas por padrão)
├── env/
│   ├── android.env          # APP_ID + credenciais placeholder (versionado)
│   ├── android.local.env    # Credenciais REAIS (gitignored)
│   └── ios.env              # Variáveis para iOS
├── flows/
│   ├── shared/                      # Rodam em Android E iOS
│   │   ├── 01_launch_smoke.yaml          # abre o app → Login
│   │   ├── 02_login_elementos.yaml       # elementos do Login
│   │   ├── 03_login_invalido.yaml        # login negativo
│   │   ├── 04_mostrar_senha.yaml         # toggle Show password
│   │   ├── 05_lembrar_email.yaml         # interação Remember email
│   │   ├── 06_navegacao_login_signup.yaml
│   │   ├── 07_signup_elementos.yaml      # tela de cadastro
│   │   ├── 08_signup_email_invalido.yaml # cadastro negativo
│   │   ├── 09_recuperar_senha.yaml       # Recover password
│   │   ├── 10_troca_idioma.yaml          # i18n login (PT/EN/ES/FR)
│   │   ├── 11_login_autenticado.yaml     # [wip] login + 2FA
│   │   ├── 12_home_elementos.yaml        # [autenticado] Home
│   │   ├── 13_navegacao_tabs.yaml        # [autenticado] bottom nav
│   │   ├── 14_conta_elementos.yaml       # [autenticado] Account
│   │   ├── 15_logout.yaml                # [autenticado] Sign out
│   │   ├── 16_automacoes_cenas.yaml      # [autenticado] Scenes/Automation
│   │   ├── 17_adesao_home.yaml           # [autenticado][escrita] criar home
│   │   ├── 18_adesao_room.yaml           # [autenticado][escrita] criar room
│   │   ├── 19_adesao_device.yaml         # [autenticado] tela Add Device
│   │   └── 20_idioma_app.yaml            # [autenticado] i18n: perfil/home/automações/cenas/ambientes (4 idiomas)
│   ├── android/
│   │   └── android_voltar.yaml      # botão físico voltar
│   └── ios/
│       └── ios_swipe_back.yaml      # swipe back (só macOS)
├── subflows/                # Blocos reutilizáveis
│   ├── dismiss_dialogs.yaml     # dispensa os 3 diálogos iniciais
│   ├── launch_app.yaml          # launch com clearState + dismiss
│   ├── open_app_logged.yaml     # launch SEM clearState (sessão viva)
│   ├── goto_login.yaml
│   ├── goto_signup.yaml
│   └── login.yaml               # e-mail/senha (login + 2FA)
└── scripts/                 # Atalhos de execução
    ├── run-android.ps1
    └── run-ios.ps1
```

## Configuração

1. O `APP_ID` (`com.syllent.connect`) já está em [`.maestro/env/android.env`](.maestro/env/android.env).
   Confirme o **bundle ID do iOS** em [`.maestro/env/ios.env`](.maestro/env/ios.env).
2. **Credenciais reais:** crie `.maestro/env/android.local.env` (já no `.gitignore`)
   com `LOGIN_USERNAME` / `LOGIN_PASSWORD`. O `run-android.ps1` carrega esse arquivo
   por cima do `android.env`. **Nunca** comite credenciais.

> O Maestro 2.6 **não** tem `--env-file`; passe variáveis com `--env KEY=VALUE`
> (os scripts `run-*.ps1` convertem o `.env` automaticamente).

## Como executar

### Android (suíte padrão — não-autenticada)
```powershell
pwsh .maestro/scripts/run-android.ps1
# equivalente:
maestro test --env APP_ID=com.syllent.connect .maestro
```
O `config.yaml` exclui por padrão as tags `wip`, `manual`, `autenticado` e `ios`.

### iOS (em macOS)
```powershell
pwsh .maestro/scripts/run-ios.ps1
```

### Filtrando por tags
```powershell
# Apenas smoke
pwsh .maestro/scripts/run-android.ps1 -IncludeTags smoke
```

### Modo interativo / validação
```bash
maestro studio                                       # inspeciona a UI
maestro check-syntax .maestro/flows/shared/01_launch_smoke.yaml
```

## Flows autenticados

A área logada exige login com **2FA por e-mail** (tela "Device authorization",
código de 6 dígitos). Esse passo **não roda headless**. Fluxo de uso:

1. Garanta credenciais em `android.local.env`.
2. **Autorize o dispositivo uma vez**, manualmente:
   - Rode o subflow de login (`11_login_autenticado`, tag `wip`) ou abra o app no
     emulador, faça login e digite o código recebido por e-mail.
3. Com a sessão estabelecida, rode os flows `autenticado` — eles abrem o app
   **sem `clearState`** (subflow `open_app_logged`), preservando a sessão:
   ```powershell
   maestro test --env APP_ID=com.syllent.connect .maestro\flows\shared\12_home_elementos.yaml
   ```
   > Não use `clearState: true` em flows autenticados — isso apaga a sessão e
   > dispara novo 2FA. O `15_logout` encerra a sessão de propósito (rode por último).

> ⚠️ **Flows com a tag `escrita` (`17_adesao_home`, `18_adesao_room`) criam dados
> reais** na conta a cada execução (uma "QA Maestro Home" / "QA Maestro Room").
> Remova-os manualmente em *Manage homes* quando necessário. O `19_adesao_device`
> apenas abre a tela "Add Device" (pareamento real exige hardware).

## Tags disponíveis

| Tag           | Descrição                                            |
|---------------|------------------------------------------------------|
| `smoke`       | Testes rápidos de sanidade                           |
| `regression`  | Suíte de regressão                                   |
| `login`       | Tela de login                                        |
| `signup`      | Tela de cadastro                                     |
| `navegacao`   | Navegação entre telas                                |
| `negativo`    | Casos de erro / validação negativa                   |
| `i18n`        | Troca de idioma                                      |
| `automacoes`  | Cenas / automações (aba Devices)                     |
| `adesao`      | Adicionar home / room / device                       |
| `escrita`     | **Criam dados reais** na conta (ver aviso abaixo)    |
| `autenticado` | Exigem sessão logada — excluídos por padrão          |
| `logout`      | Encerra a sessão (rodar isolado)                     |
| `android`     | Específicos de Android                               |
| `ios`         | Específicos de iOS (só macOS) — excluídos por padrão |
| `wip`         | Em desenvolvimento — excluídos por padrão            |

## Escrevendo novos flows

- Reaproveite os subflows com `runFlow: ../../subflows/<nome>.yaml`.
- Para comportamento por plataforma, use `runFlow` com `when: platform: Android|iOS`.
- Este app é **React Native**: prefira seletores por **texto**/accessibility label.
  Para campos ambíguos (ex.: senha), use `index`. Há poucos `resource-id`.
- Consulte a [referência de comandos](https://docs.maestro.dev/api-reference/commands).
