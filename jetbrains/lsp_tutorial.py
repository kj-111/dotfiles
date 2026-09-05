"""Oefenbestand: alles wat de "LSP" van PyCharm voor je doet.

Open dit in PyCharm (Windows-keymap) en werk de secties van boven naar
beneden af. Elke oefening zegt welke shortcut je moet proberen.
Runnen kan gewoon: Ctrl+Shift+F10 (de kapotte oefencode wordt niet aangeroepen).
"""

from dataclasses import dataclass


# ── 1. DOCUMENTATIE ─────────────────────────────────────────────────
# Zet je cursor op `sorted` hieronder en druk Ctrl+Q  → documentatie-popup.
# Druk nogmaals Ctrl+Q om de popup vast te pinnen. Esc sluit.
# Probeer ook Ctrl+Q op `len`, `dict.get` en op `Speler` (eigen klasse, verderop).

getallen = sorted([3, 1, 2])

# Zet je cursor TUSSEN de haakjes van round() en druk Ctrl+P  → signature help:
# je ziet (number, ndigits). Typ een komma en kijk hoe de actieve parameter meebeweegt.

afgerond = round(3.14159, 2)

# Selecteer de hele expressie hieronder (of zet er je cursor op) en druk
# Ctrl+Shift+P  → toont het afgeleide type (dict[str, list[int]]).

per_team = {"rood": [1, 2], "blauw": [3]}


# ── 1b. SIGNATURE & RETURNTYPE LEZEN ────────────────────────────────
# Onbekende functie? Zo lees je in 3 stappen wat erin moet en wat eruit komt:
#   1. Ctrl+Q op de functienaam      → volledige signature + docs + returntype
#   2. Ctrl+P tussen de haakjes      → welke parameter je NU aan het invullen bent
#   3. Ctrl+Shift+P op de aanroep    → welk type het resultaat heeft
# Probeer alle drie op de regels hieronder:

inhoud_regels = "a,b;c".split(";")          # wat geeft split terug? (Ctrl+Shift+P)
genummerd = list(enumerate(["x", "y"]))     # wat verwacht enumerate? (Ctrl+P: start=?)
opgezocht = per_team.get("groen", [])       # wat is het returntype mét default? (Ctrl+Q op get)


# ── 2. COMPLETION ───────────────────────────────────────────────────
@dataclass
class Speler:
    """Een speler met naam en score. (Bekijk mij met Ctrl+Q!)"""

    naam: str
    score: int = 0

    def verdubbel_score(self) -> int:
        """Verdubbelt de score en geeft de nieuwe waarde terug."""
        self.score *= 2
        return self.score


def oefen_completion() -> None:
    speler = Speler("Jean", 10)
    # Typ hieronder `speler.` en bekijk de lijst: alle attributen en methods.
    # Ctrl+Space forceert de lijst als ze wegklikt. Ctrl+Q in de lijst = docs
    # van de geselecteerde suggestie. Enter voegt in, Tab vervangt.

    # Typ hier: spe...  → en accepteer `speler` met Tab.

    # Complete statement: typ `if speler.score > 5` ZONDER dubbelpunt en druk
    # Ctrl+Shift+Enter  → PyCharm zet de `:` en springt naar de juiste plek.

    # Type name completion: typ hieronder `Coun` en druk Ctrl+Alt+Space
    # → suggereert Counter uit collections én voegt de import bovenaan toe.
    print(speler)


# ── 3. NAVIGATIE ────────────────────────────────────────────────────
def oefen_navigatie() -> None:
    s = Speler("Ada", 5)
    # Cursor op `verdubbel_score` → Ctrl+B springt naar de definitie (jouw gd).
    # Ga terug met Ctrl+Alt+←  (jouw Ctrl+O jumplist).
    # Ctrl+Shift+I op dezelfde naam = peek: definitie in een popup, zonder sprong.
    s.verdubbel_score()
    # Alt+↑ / Alt+↓ springt tussen functies in dit bestand.
    # Ctrl+F12 = structure-popup: alle functies/klassen, typ om te filteren.


# ── 4. DIAGNOSTICS & QUICK FIXES (hier staan expres fouten!) ────────
def oefen_quick_fixes() -> None:  # (wordt bewust niet aangeroepen)
    # `sqrt` is rood: import ontbreekt. Cursor erop → Alt+Enter → "Import math..."
    wortel = sqrt(16)

    # Onbekende naam (typfout). F2 springt naar de volgende fout in het bestand,
    # Ctrl+F1 toont de foutmelding, Alt+Enter geeft fixes (bv. hernoemen).
    print(worttel)

    # Ongebruikte variabele (grijs): Alt+Enter → "Remove variable".
    ongebruikt = 42


# ── 5. REFACTOREN ───────────────────────────────────────────────────
def bereken_totaal(spelers: list[Speler]) -> int:
    # Cursor op `totaal` → Shift+F6 → hernoem naar bv. `som` → overal tegelijk
    # aangepast, ook in de return. Werkt net zo op functies en klassen.
    totaal = 0
    for speler in spelers:
        totaal += speler.score
    return totaal


# ── 6. BEWERKEN (deze functie staat expres lelijk geformatteerd) ────
def oefen_bewerken():
    x=1;y   =2
    # Ctrl+Alt+L  → reformat: alles hierboven wordt netjes PEP8.
    # Ctrl+D dupliceert deze regel. Alt+Shift+↑/↓ verplaatst ze.
    # Ctrl+W (herhaald) breidt je selectie uit: woord → expressie → regel → blok.
    # Ctrl+/ zet een regel in commentaar. Ctrl+Y verwijdert een regel (géén redo!).
    return x + y


# ── 7. DEBUGGEN ─────────────────────────────────────────────────────
def gemiddelde(scores: list[int]) -> float:
    # Zet een breakpoint op de return-regel (Ctrl+F8 of klik in de kantlijn),
    # start met Shift+F9 en inspecteer `totaal` en `len(scores)`.
    # F8 = step over, F7 = step into, Alt+F8 = evaluate expression
    # (probeer daar: sum(scores) / len(scores)).
    totaal = sum(scores)
    return totaal / len(scores)


def main() -> None:
    spelers = [Speler("Jean", 10), Speler("Ada", 5)]
    oefen_completion()
    oefen_navigatie()
    print("Totaal:", bereken_totaal(spelers))
    print("Bewerken:", oefen_bewerken())
    print("Gemiddelde:", gemiddelde([10, 5, 9]))


if __name__ == "__main__":
    main()
