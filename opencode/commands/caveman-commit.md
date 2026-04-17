---
description: Genereer korte commitboodschap
---
Schrijf een korte, exacte commit message.

Regels:
- Gebruik Conventional Commits: `<type>(<scope>): <imperative summary>`.
- `scope` is optioneel.
- Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`.
- Kies waarom boven wat.
- Subject idealiter <= 50 tekens, harde limiet 72.
- Geen punt aan het einde van de subject line.
- Body alleen als reden, breaking change of migratiestap anders onduidelijk blijft.
- Body op 72 kolommen, met `-` voor bullets.
- Geen AI-attributie, geen `This commit`, geen herhaling van bestandsnamen.
- Volg taalconventie van de repo; als die onduidelijk is, gebruik Engels.

Output alleen de commitboodschap in een codeblok, klaar om te plakken.
