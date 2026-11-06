# POCO F7 (onyx) — Game & Performance Tweaks  ·  v3.1.0

Módulo **Magisk / KernelSU / APatch** para o POCO F7 (codinome `onyx`,
Snapdragon 8s Gen 4 / Adreno 825), para ROMs AOSP / LineageOS / **AxionAOSP**.
**Versão sem driver de GPU** — segura, não troca nenhuma lib de vendor.

## 🔋 v3.4.0 — Economia de bateria (segura) + descoberta do sconfig
- **Economia de bateria** que NÃO afeta a fluidez: mexe só em segundo
  plano/standby (desativa scan de Wi-Fi/BT em background, garante Doze e o
  congelamento de apps em cache). Toggle na WebUI, totalmente reversível.
- **Cenas térmicas do onyx**: os perfis existem (`normal`, `mgame`/`hp-mgame`,
  `highfps`, `nolimits`), mas o **número** de cada `sconfig` é definido pelo
  thermald da Xiaomi e não há tabela pública confiável. Por isso **não** embuto
  um valor "performance". Em vez disso: inicie o **Monitor**, abra um jogo e veja
  o `sconfig` mudar — esse é o número do perfil de jogo do *seu* aparelho; use-o
  no campo **custom** do card térmico.

## 🌡️ v3.3.0 — Monitor ao vivo + Perfil térmico
Inspirado no **Project-Raco** (LoggingNewMemory):
- **Monitor (ao vivo)** na WebUI: modelo, kernel, bateria + temperatura,
  temperatura do SoC (zona mais quente), governor e frequências de CPU, GPU
  (freq + governor), RAM livre, refresh rate e o valor térmico atual. Só leitura.
- **Perfil térmico**: usa o nó do próprio aparelho
  `/sys/class/thermal/thermal_message/sconfig`:
  - **Padrão** → `sconfig=0` (perfil "normal" verificado) + powersave off;
  - **Resfriar** → `powersave_mode=1` (mais conservador, esquenta menos);
  - **Custom (nº)** → para quem conhece a cena térmica do onyx (com aviso).
  > Não embuto um valor que **desliga** a proteção térmica: o mapa de cenas do
  > onyx fica num blob do vendor e um número errado poderia superaquecer. O
  > perfil é sempre reversível pelo botão **Padrão**.

## ✅ v3.1.0 — removido o driver de GPU
A versão v3.0.x embutia o driver Adreno V842.52, que causou **bootloop** na
Adreno 825 (driver incompatível). Esta versão **remove o driver por completo** e
mantém só os tweaks, que são seguros e não substituem nenhuma lib de sistema.

> Se você ainda estiver em bootloop da v3.0.x: ligue em **Safe Mode** (segure
> `Volume –` no boot) para desativar os módulos, ou remova pelo recovery a pasta
> `/data/adb/modules/onyx_gameperf`, depois instale esta v3.1.0.

---

## ✨ Novidades da v2.2.0
- **Seletor de idioma na WebUI** — escolha entre vários idiomas (pt-BR, en, es,
  fr, de, ja, ko, zh, ru…). Aplica no Fortnite (botão do topo) e **por jogo**
  no editor (botão 🌐 em cada linha), via `cmd locale` (Android 13+).

## Novidades da v2.1.0
- **Editor de jogos na WebUI** — ligue/desligue, adicione e remova jogos pela
  tela; salva em `games.list`.

## Novidades da v2.0.0
- **Interface / painel de controle (WebUI)** no KernelSU / APatch / MMRL.
- **Botão de ação** no Magisk (`action.sh`) para reaplicar na hora.
- **Idioma do Fortnite (pt-BR)** — tentativa automática + passo manual.
- **Opção experimental de 120 FPS** (desligada por padrão, com avisos).
- Lista de jogos **editável** em `/data/adb/onyx_gameperf/games.list`.

---

## O que o módulo faz
1. **Gráficos / menos borrado em jogos** — força o **GameManager** em *modo
   performance* e **desativa o downscale** de resolução (renderiza na resolução
   cheia) para Fortnite, PUBG, COD, Free Fire, Genshin, Honkai, Wild Rift,
   Mobile Legends, Minecraft, Roblox e outros.
2. **Performance geral** — ajustes leves e seguros de I/O e memória.
3. **Idioma do Fortnite** — tenta definir pt-BR por app (ver limites abaixo).

---

## 🖥️ Interface (como abrir)
- **KernelSU / APatch / MMRL:** abra o app gerenciador → aba Módulos → neste
  módulo toque em **“Open WebUI”** (ou no ícone/ação). O painel mostra status e
  botões (aplicar tweaks, corrigir idioma, 120 FPS, ver log).
- **Magisk:** o Magisk não tem WebUI. Use o botão **“Action”** do módulo (Magisk
  26.4+), que reaplica os tweaks e corrige o idioma.

---

## 🎯 Fortnite borrado mesmo no Ultra — a causa está no JOGO
O módulo **não altera** as configurações do Fortnite (nem deveria — a Epic
valida isso). Pela sua print, o borrado vem daqui:
- **Anti-Aliasing & Super Resolution = `Qualcomm GSR`** → o GSR renderiza numa
  resolução interna menor e amplia, o que deixa a imagem “mole”.

**Ajuste no jogo (Configurações → Vídeo):**
1. **Anti-Aliasing & Super Resolution** → troque para **`TAA`** (ou **`High`**).
2. **3D Resolution** → **100%**.
3. **Rendering Mode** (Advanced Graphics) → modo nativo, não o de economia.
4. **Textures / View Distance** → **Epic**.
5. Reinicie o Fortnite depois de trocar.

---

## 🌐 Idioma do Fortnite em inglês
O Fortnite é Unreal Engine e normalmente segue o **idioma do sistema**. O botão
“Corrigir idioma” tenta `cmd locale set-app-locales` (Android 13+), mas a UE
pode ignorar. **Correção confiável:**
1. **Config → Sistema → Idiomas** → deixe **Português (Brasil)** como **1º** da
   lista (não só adicionado — tem que estar no topo).
2. **Config → Apps → Fortnite → Armazenamento → Limpar cache** (não limpe dados).
3. Abra o Fortnite de novo.

> Se o Fortnite foi instalado pela loja da Epic/terceiros, os idiomas ficam nos
> paks; com o sistema em pt-BR ele deve seguir. Se persistir, reinstalar com o
> sistema já em pt-BR resolve na maioria dos casos.

---

## ⚠️ 120 FPS no Ultra — a verdade
A **Epic nunca liberou 120 FPS no Android** e **bloqueia pelo servidor**. Não
existe forma garantida. O único método da comunidade é *spoof* de modelo do
aparelho, que:
- **quase sempre não funciona** (a Epic trava do lado do servidor);
- **viola os Termos da Epic**;
- pode **quebrar Play Integrity** → apps de banco, Google Wallet, etc.;
- tem risco **pequeno, mas real, de ban**.

Por isso o spoof vem **desligado** e eu **não recomendo**. Se mesmo assim quiser
testar, ative pela WebUI (pede confirmação) e reinicie. Para desligar, use a
WebUI de novo e reinicie.

---

## 📁 Arquivos / depuração
- Log: `/data/adb/onyx_gameperf/service.log`
- Lista de jogos editável: `/data/adb/onyx_gameperf/games.list`
- Reaplicar manualmente (terminal root):
  `sh /data/adb/modules/onyx_gameperf/scripts/apply-tweaks.sh`

## Reverter
Desative/remova o módulo no gerenciador e reinicie. Tudo é systemless; nada é
gravado de forma permanente. Se tiver ativado o spoof 120 FPS, desative antes de
remover (ou apenas remova e reinicie — as props spoofadas somem no boot limpo).
