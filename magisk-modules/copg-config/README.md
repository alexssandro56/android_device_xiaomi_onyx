# COPG config — spoof por jogo (POCO F7 / onyx)

Config pronta pro módulo **COPG** (Change Our Phone Game), que é **Zygisk** e faz
spoof de aparelho **por jogo** (sem afetar o resto do sistema) — o que um módulo
shell não consegue.

## O que esta config faz
Faz os jogos listados acharem que o aparelho é um **RedMagic 9 Pro (ZTE NX769J)**,
um celular gamer que costuma destravar presets gráficos / FPS maiores. Jogos
incluídos: PUBG/BGMI, COD Mobile, Free Fire, Mobile Legends, Wild Rift, Genshin,
Honkai: Star Rail, Asphalt 9, Farlight 84.

## Como usar
1. Instale o **Zygisk** (Magisk Zygisk ON, ou KernelSU/APatch + ZygiskNext).
2. Instale o módulo **COPG** (AlirezaParsi/COPG) e reinicie.
3. Substitua o arquivo `/data/adb/modules/COPG/COPG.json` por **este**
   (ou cole o conteúdo dele pela WebUI do COPG).
4. Reinicie. Abra o jogo e veja se liberou presets/FPS maiores.

> Dica: a **WebUI do COPG** já tem presets de aparelhos com `FINGERPRINT`
> correto. Esta config usa BRAND/MODEL/DEVICE/MANUFACTURER (o que destrava
> gráficos na maioria dos jogos). Se um jogo específico exigir fingerprint,
> escolha o preset "RedMagic 9 Pro" na WebUI do COPG em vez de editar à mão.

## ⚠️ Avisos (importante)
- **Risco de ban:** spoofar aparelho em jogos **competitivos** (PUBG, COD, Free
  Fire, Mobile Legends, Wild Rift) **viola o ToS** e pode resultar em banimento.
  Use por sua conta e risco; de preferência só em jogos single-player.
- **Play Integrity:** o COPG é por app, então apps de banco/Wallet **não** são
  afetados (ao contrário do spoof global do módulo principal). Ainda assim,
  confira depois de ativar.
- **Fortnite 120fps NÃO:** a Epic bloqueia 120fps no Android pelo servidor;
  spoof de aparelho não resolve. Por isso o Fortnite não está nesta lista.
- Para reverter: remova o COPG (ou tire os jogos da lista) e reinicie.

## Trocar o aparelho fingido
Troque os valores em `PACKAGES_REDMAGIC9PRO_DEVICE` (BRAND/MODEL/DEVICE) por
outro aparelho, ou crie mais blocos `PACKAGES_<NOME>` + `PACKAGES_<NOME>_DEVICE`
para grupos de jogos diferentes.
