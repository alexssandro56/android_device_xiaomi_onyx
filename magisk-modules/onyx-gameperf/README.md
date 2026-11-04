# POCO F7 (onyx) — Game & Performance Tweaks  ·  v2.0.0

Módulo **Magisk / KernelSU / APatch** para o POCO F7 (codinome `onyx`,
Snapdragon 8s Gen 4), para ROMs AOSP / LineageOS / **AxionAOSP**.
Agora com **interface (WebUI)**.

---

## ✨ Novidades da v2.0.0
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
