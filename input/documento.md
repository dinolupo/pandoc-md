---
title: "Documento di Prova Aziendale"
author: "Mario Rossi"
date: "2 Luglio 2025"
---

# Introduzione

Questo è un documento di esempio per dimostrare le capacità del convertitore basato su Pandoc e LaTeX. Include testo formattato, elenchi e diagrammi generati dinamicamente.

## Diagramma di Sequenza (PlantUML)

Il seguente diagramma mostra un semplice flusso di autenticazione.

```plantuml
@startuml
autonumber

Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: Another authentication Response
@enduml
```

## Diagramma a Grafo (Mermaid)

Questo diagramma illustra una semplice relazione tra componenti.

```mermaid
graph TD;
    A[Start] --> B{Decisione};
    B -->|Sì| C[Modulo 1];
    B -->|No| D[Modulo 2];
    C --> E[Fine];
    D --> E[Fine];
```

# Conclusione

Come si può vedere, i diagrammi sono stati renderizzati e inclusi correttamente nel documento, che seguirà il layout definito nel template LaTeX.
