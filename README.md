# claude-skills

Особисті скіли Claude Code, які **не** їдуть у TFVC разом із `$/ITnet2`.

| Скіл | Призначення |
|---|---|
| `skills/changes-description` | опис виконаних змін для вставки в ITA |
| `skills/worklog-entries` | текстовки для журналу робіт (Timesheet) |

## Як вони підключаються

Claude Code шукає скіли у `<проєкт>\.claude\skills\` та в `~\.claude\skills\`.
Репозиторій лежить окремо, а в цих каталогах стоять **junction'и** на його теки -
код розробляється тут і версіонується git'ом, а Claude бачить його за звичним шляхом.

Розгорнути на машині / у новому проєкті:

    .\setup.ps1                                  # у D:\ITA\ITNet2 (типово)
    .\setup.ps1 -ProjectRoot C:\ITnet2\ITnet2    # інший робочий каталог
    .\setup.ps1 -Scope User                      # у ~\.claude\skills - видно з усіх проєктів

Прибрати: `.\setup.ps1 -Remove`.

Junction - не копія: правки у `skills\...` одразу діють у Claude, і навпаки.
