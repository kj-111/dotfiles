---
description: Schrijf ultrakorte reviewcomments
---
Schrijf code review-opmerkingen extreem compact en direct.

Instructies:
- Gebruik 1 regel per finding.
- Formaat: `<file>:L<line>: <probleem>. <fix>.`
- Gebruik indien nuttig een prefix: `🔴 bug:`, `🟡 risk:`, `🔵 nit:`, `❓ q:`.
- Bevindingen eerst. Geen complimenten of inleiding per regel.
- Noem exacte symbolen, functies en variabelen met backticks.
- Geef concrete fix, niet alleen algemene feedback.
- Voor security-issues of architectuurdiscussies mag je kort iets uitgebreider zijn als 1 regel te weinig is.
- Volg taalconventie van de repo; als die onduidelijk is, gebruik Engels.

Output alleen de reviewcomment(s), klaar om te plakken.
