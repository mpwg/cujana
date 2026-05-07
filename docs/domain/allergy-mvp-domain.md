# Allergy MVP Domain

Die Allergy-Domain beschreibt fachliche Konzepte und keine technischen Datenquellen, UI-Zustände oder Persistenzmodelle.
Sie liegt unter `Cujana/Domain` und darf nur `Foundation` importieren.

## Erweiterung um Health-Aspekte

Neue Gesundheitsaspekte werden als eigene Entities und Value Objects in der Domain ergänzt, sobald sie fachliche Regeln haben.
Beispiele sind Schlaf, Atemwegsgesundheit oder Medikamenteneinnahmen. Presentation Models und Views mappen später auf diese
Domain-Werte, statt UI-Entscheidungen in die Domain zu ziehen.

## Erweiterung um Hintergrundinformationen

Weitere Hintergrundinformationen werden als fachlich benannte Entities und Repository-Protokolle modelliert. Technische Quellen
wie APIs, Dateien oder lokale Caches bleiben Infrastrukturdetails hinter diesen Protokollen. Anbieter- oder DTO-Namen gehören
nicht in die Domain, wenn sie nicht fachlich relevant sind.

## Therapie und Prophylaxe

Therapie- und Prophylaxe-Daten gehören fachlich neben Symptome und Hintergrundinformationen in die Domain. Sie sollten eigene
Entities, Value Objects und Use Cases bekommen, zum Beispiel für Maßnahmen, Medikationshinweise oder persönliche Routinen.
Konkrete Erinnerungssysteme, Benachrichtigungen und Persistenz werden erst in App, Features oder Infrastructure angebunden.
