# POCO F7 (onyx) — Game & Performance Tweaks

Módulo **Magisk / KernelSU / APatch** para o POCO F7 (codinome `onyx`,
Snapdragon 8s Gen 4), feito para ROMs AOSP / LineageOS / **AxionAOSP**.

## O que ele faz

1. **Gráficos / Fortnite menos borrado** — força o **GameManager** do Android a
   usar *modo performance* e, principalmente, **desativa o downscale** de
   resolução dos jogos. O downscale automático é a causa mais comum de imagem
   "mole"/borrada, então o jogo passa a renderizar na resolução cheia.
   Aplica para Fortnite, PUBG, COD, Free Fire, Genshin, Honkai Star Rail,
   Wild Rift, Mobile Legends, Minecraft, Roblox e outros.
2. **Performance geral** — ajustes leves e seguros de I/O (scheduler de baixa
   latência, read-ahead) e de memória (swappiness/ZRAM, dirty ratios).
3. **Props de GPU/render** — mantém tracing desligado e ativa o
   *performance hint manager* (ADPF) para melhor ritmo de quadros.

## O que ele NÃO faz (e por quê, com sinceridade)

- **Não "melhora os drivers".** O driver da GPU Adreno e o kernel são blobs
  pré-compilados; um módulo não reescreve driver. Ele só muda *configurações*
  que o driver/sistema leem.
- **Não força governor "performance" nem desliga o throttling térmico.**
  No 8s Gen 4 isso só esquenta e gasta bateria sem FPS sustentado a mais — e
  desligar térmico é arriscado. O scheduler EAS de fábrica já sobe sozinho.
- **Não garante Fortnite 100% nítido.** A Epic tem um *render scale* interno
  próprio por limite térmico/performance. Desativar o downscale do sistema
  ajuda, mas a palavra final é do jogo. **Dentro do Fortnite**, coloque
  *Resolução 3D = 100%* e qualidade *Alta/Épica* para o melhor resultado.

## Instalar

1. Baixe o `.zip` do módulo.
2. Magisk → Módulos → *Instalar pelo armazenamento* (ou KernelSU/APatch → Módulos).
3. Reinicie.

## Verificar / depurar

Depois de reiniciar, o log fica em:

```
/data/local/tmp/onyx_gameperf.log
```

Para conferir manualmente as intervenções de um jogo (via adb/terminal root):

```
cmd game set --mode performance --downscale disable com.epicgames.fortnite
```

## Reverter

Desative/remova o módulo no app (Magisk/KernelSU/APatch) e reinicie. Nada é
gravado de forma permanente nas partições — tudo é systemless.
