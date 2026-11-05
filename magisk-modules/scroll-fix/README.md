# Scroll Fix (120Hz lock) — POCO F7 (onyx)

Módulo **Magisk / KernelSU / APatch** que deixa a **rolagem dos apps lisa**
travando o display em **120Hz** (impede a queda para 60Hz durante o scroll).

## Por que o módulo original travava
O `SF_Scroll_Fix_13.6ms` fazia só isto no boot:

```
service call SurfaceFlinger 1047 i64 13600000 i64 16600000 i64 16600000
```

Problemas no POCO F7 (painel 120Hz):
- **Valores de 60Hz** (16.6 ms = 1/60) num painel de **120Hz** (8.33 ms) →
  atraso de ~2 frames → **engasga a rolagem**.
- O código de transação **`1047` é específico de versão** do Android; na sua
  ROM pode cair em outra função (ou nenhuma).
- É um **tiro único**: ao trocar 60↔120Hz, o SurfaceFlinger **reseta** tudo.
- A ROM onyx **já afina** as durações do SF para 120Hz.

## O que esta versão faz
Trava o refresh em 120Hz via as configurações padrão do Android (mesma coisa do
“Smooth Display”, porém forçado e reaplicado):

```
settings put system min_refresh_rate 120
settings put system peak_refresh_rate 120
```

Isso **persiste** e sobrevive às trocas de refresh — é o jeito confiável de
acabar com o scroll a 60Hz. **Não** mexe em lib de vendor → sem risco de brick.

## Observação
Travar em 120Hz **gasta um pouco mais de bateria** (a tela nunca cai para 60Hz
parada). Se quiser equilíbrio, troque `120` por `90` no `service.sh`.

Log: `/data/local/tmp/onyx_scroll_fix.log`

## Reverter
Remova o módulo e reinicie. Para voltar ao automático na hora:
`settings put system min_refresh_rate 60` (ou ajuste em Config → Tela).
