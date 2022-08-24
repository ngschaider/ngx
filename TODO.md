TODO:

- Konsistent wo möglich vector2/vector3 verwenden 
- menu-Modul um NativeUI ordentlich zu integrieren
- marker-Modul (Marker hinzufügen, entfernen) (reines Utility-Modul)
- command-Modul erweitern und testen (reines Utility-Modul)
    Optionaler Hilfetext für den ein chat:addSuggestion Event gesendet wird
    2 Modi:
        Mit dem Parsen von Argumenten:
            Möglichkeit von automatischen Validators für Typen Spieler, Fahrzeug, Item
        Ohne dem Parsen von Argumenten:
            Alle Argumente werden direkt an die CB-Funktion übergeben (ohne den Befehl zu beinhalten)
- vehicle-Modul für Fahrzeuge in Charakterbesitz
- document-Modul für diverse Lizenzen und Dokumente (Führerscheine, Waffenschein, Ausbildungen, Bescheinigungen)
- weapon-Modul für Waffen in Charakterbesitz
- house-Modul für Häuser in Charakterbesitz
- pet-Modul für Tiere in Charakterbesitz
- pedestrian-Modul um Standard-NPC-Verkehr zu regeln/auszuschalten
- zone-Modul / area-Modul um Flächen auszuwählen (reines Utility-Modul)
- chat-Modul (braucht man sowas überhaupt?)

Muss getestet werden:
- OOP mit Vererbung umsetzen (class-Modul?)
    class-Modul auf Basis der Library middleclass implementiert
- Inventarsystem fertig implementieren (Vererbung?)

Nicht umgesetzt:
- Moduldateien nach Prefix importieren (sv_, cl_, sh_), keine festgelegten Dateinamen mehr
    Reihenfolge des Imports kann nicht automatisch erkannt werden
- vector3 und vector2 implementieren als Klassen
    FiveM-Vektoren haben gute Unterstützung mit den Natives