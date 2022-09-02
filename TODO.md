# TODO:

### * Sicherheitskonzept für RPC's und Syncvalues implementieren
- Syncvalues: Wie definiere ich, welcher Client, welche Werte lesen darf?
- RPC's: Wie definiere ich, welcher Client, welche Werte schreiben darf/welche Funktionen aufrufen darf?


### * Caching verbessern und Sync implementieren.
#### Klasse DataObject
- Diese Klasse kümmert sich im Konstruktor um die Abfrage der Daten aus der DB und speichert diese im _data property ab
- Hat zwei Methoden: getData und setData
- getData gibt einfach den Wert aus dem _data property zurück
- setData setzt den Wert in der DB, setzt den Wert im _data property und triggert ein Event an alle Clients die über das Objekt Bescheid wissen.
- Die Existenz von externen Entitäten muss immer über einen eine DB-Abfrage erfolgen um veraltete Werte zu vermeiden (z.B. ist es in einem modularen System schwer Möglich nach dem Aufrufen von Item.destroy die ID auch aus jedem Inventar zu entfernen, daher sollte Inventory.getItems und Inventory.getItemIds immer frische Werte aus der DB abfragen)

#### Klasse SyncedDataObject (erbt von DataObject)
- User, Character, Inventory, Item, ... erben von dieser Klasse
- Bietet die Möglichkeit die Daten des _data Property über einen Callback an Clients auszuliefern, und merkt sich welche Clients über das Objekt Bescheid wissen
- Kümmert sich auch um die Implementierung von RPC's



- Vec2.fromVector3 - Bekommt einen vector3 als Parameter übergeben, übernimmt X-, und Y-Werte in ein neues Vec2 und ignoriert den Z-Wert
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
- Vec2 wurde als Klasse implementiert

Nicht umgesetzt:
- Moduldateien nach Prefix importieren (sv_, cl_, sh_), keine festgelegten Dateinamen mehr
    Reihenfolge des Imports kann nicht automatisch erkannt werden
- vector3 vorerst nicht implementiert, da noch nicht notwendig (Vec2 kann zu vector3 konvertiert werden)