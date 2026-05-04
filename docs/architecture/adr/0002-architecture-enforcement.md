# ADR-0002: Architektur wird durch Guardrails enforced

Status: Akzeptiert  
Datum: 2026-05-04

## Kontext

Architekturdokumente verlieren schnell Wirkung, wenn sie nicht automatisch überprüft werden. Cujana soll wartbar bleiben, auch wenn Features schnell wachsen.

Da der Start als modularer Monolith bewusst ohne harte Modulgrenzen erfolgt, müssen die Grenzen durch leichte, verständliche Guardrails geschützt werden.

## Entscheidung

Cujana nutzt mehrere Enforcement-Ebenen:

1. Dependency-freies Bash-Skript für Architekturregeln.
2. SwiftLint für Stil und zusätzliche Regex-Regeln.
3. GitHub Actions als Merge-Gate.
4. Pull-Request-Template für bewusste Architekturprüfung.
5. CODEOWNERS für Architekturdateien.
6. ADR-Pflicht bei strukturellen Änderungen.
7. Maschinenlesbare Architekturregeln in `.cujana/architecture.yml`.

## Konsequenzen

Vorteile:

- Verstöße werden früh erkannt.
- Regeln sind im Repository sichtbar.
- Neue Entwickler sehen die Erwartungen direkt.
- Architektur kann sich weiterentwickeln, bleibt aber nachvollziehbar.

Nachteile:

- Regeln müssen gepflegt werden.
- Falsch-positive Checks können auftreten.
- Ausnahmen brauchen bewusste Dokumentation.

## Alternativen

### Nur Code Review

Verworfen, weil manuelle Reviews inkonsistent sind.

### Sofort harte Swift-Package-Grenzen

Verworfen, weil das für den Projektstart zu viel Struktur erzwingt.

### Nur SwiftLint

Verworfen, weil nicht alle Architekturregeln gut in SwiftLint abbildbar sind und das Projekt auch ohne lokal installiertes SwiftLint prüfbar bleiben soll.

## Enforcement

Die zentrale lokale Prüfung ist:

```bash
make architecture-check
```

CI führt denselben Check aus. Änderungen an diesem Prozess erfordern ein ADR.
