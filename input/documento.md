---
title: "Linee Guida Architetturali"
subtitle: "Progetto CSE Fornitori - FASE 2"
author: ["GFT Italia"]
date: "15 Luglio 2025"
subject: "Architettura Software"
keywords: [microservizi, modernizzazione, cloud-native, OpenShift]
lang: "it"
# titlepage: true
# titlepage-color: "1E90FF"
# titlepage-text-color: "FFFFFF"
# titlepage-rule-color: "FFFFFF"
# titlepage-rule-height: 2
titlepage: true
titlepage-text-color: "7137C8"
titlepage-rule-color: "7137C8"
titlepage-rule-height: 2
logo: "assets/client.png"
logo-width: 120

toc: true
toc-own-page: true
colorlinks: true
header-includes:
  - \usepackage{fontspec, lastpage, graphicx}
  - \defaultfontfeatures{Ligatures=TeX}
linkcolor: black
table-use-row-colors: true
header-right: "\\includegraphics[width=2cm]{/data/assets/logo.png}"
footer-right: " GFT Technologies SE 2025"
footer-left: "\\thepage/\\pageref{LastPage}"
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
