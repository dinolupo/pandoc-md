---
# https://github.com/Wandmalfarbe/pandoc-latex-template
title: "Linee Guida Architetturali"
subtitle: "Progetto PizzaFichi SRL Fornitori - Fase 2"
author: ["GFT Italia"]
date: "15 Luglio 2025"
subject: "Architettura Software"
keywords: [microservizi, modernizzazione, cloud-native, OpenShift]
lang: "it"
watermark: "draft"
titlepage: true
titlepage-rule-height: 2
titlepage-logo: "/data/assets/client.png"
# titlepage-color: "1E90FF"
# titlepage-text-color: "FFFFFF"
# titlepage-rule-color: "FFFFFF"

toc: true
toc-own-page: false
colorlinks: true
header-includes:
  - \usepackage{fontspec, lastpage, graphicx}
  - \defaultfontfeatures{Ligatures=TeX}
  - |
    ```{=latex}
    \usepackage{awesomebox}
    \usepackage{tcolorbox}
    \newtcolorbox{info-box}{colback=cyan!5!white,arc=0pt,outer arc=0pt,colframe=cyan!60!black}
    \newtcolorbox{warning-box}{colback=orange!5!white,arc=0pt,outer arc=0pt,colframe=orange!80!black}
    \newtcolorbox{error-box}{colback=red!5!white,arc=0pt,outer arc=0pt,colframe=red!75!black}
    ```

linkcolor: black
table-use-row-colors: true
header-right: "\\includegraphics[width=2cm]{/data/assets/logo.png}"
footer-right: "GFT Technologies SE 2025"
footer-center: "draft v.0.1"
footer-left: "\\thepage/\\pageref{LastPage}"

pandoc-latex-environment:
  noteblock: [note]
  tipblock: [tip]
  warningblock: [warning]
  cautionblock: [caution]
  importantblock: [important]
  tcolorbox: [box]
  info-box: [info-box]
  warning-box: [warning-box]
  error-box: [error-box]
---

# Introduzione

## Scopo del documento
Questo documento definisce l'approccio architetturale, le best practice e le linee guida per la modernizzazione degli applicativi Cobol (denominati FR) da ambiente HOST a piattaforma cloud-native su OpenShift. L'obiettivo è fornire una visione completa della trasformazione tecnologica che va oltre la semplice migrazione del codice, abbracciando principi di architettura moderna, osservabilità avanzata e operational excellence.

## Contesto e obiettivi strategici
La reingegnerizzazione di DeliveryProject rappresenta un'opportunità strategica per PizzaFichi SRL di modernizzare la propria infrastruttura tecnologica, migliorare l'agilità di business e ridurre la dipendenza dal mainframe legacy. Gli obiettivi chiave includono:

1. **Modernizzazione tecnologica**: Transizione da architettura monolitica mainframe a microservizi cloud-native
2. **Miglioramento dell'agilità**: Abilitazione di cicli di sviluppo più rapidi e deployment continuo
3. **Riduzione dei costi operativi**: Ottimizzazione delle risorse e automazione dei processi
4. **Incremento della resilienza**: Implementazione di pattern di fault tolerance e disaster recovery
5. **Abilitazione dell'osservabilità**: Implementazione di monitoring, logging e tracing distribuito
6. **Preparazione per il futuro**: Creazione di fondamenta per ulteriori innovazioni tecnologiche

| AS-IS | TO-BE |
|-------|-------|
| Componenti FR in ambiente HOST | Funzionalità esposte da un microservizio deployato su OpenShift (più FR potrebbero convogliare su singolo microservizio, a seconda del perimetro funzionale considerato) |
| Chiamate sincrone HTTP con payload XML | REST API per i nuovi microservizi; ACL di traduzione per non impattare i consumer legacy |
| Accesso a moduli CICS/COBOL via WZHC | Invariato: i microservizi invocano WZHC via HTTP POST XML |
| Scrittura dati su DB2 | Schema invariato; insert/update gestiti dai microservizi |
| Sicurezza basata su token utente | DA CONFERMARE: token utente -> token tecnico, validazione tramite servizio esterno |

## Glossario
Definizione dei principali termini tecnici utilizzati nel documento.

| Sigla | Descrizione |
|-------|-------------|
| REST | Representational State Transfer, stile architetturale formato da vincoli, linee guida e best practice che utilizza HTTP per la comunicazione tra client e server. |
| SOAP | Protocollo di messaggistica basato su XML per lo scambio di informazioni strutturate in ambienti distribuiti e utilizzato per le comunicazioni verso i sistemi B2B |
| HLA | High Level Architecture |
| ATE | Analisi Tecnica |
| API | Definizione del contratto con cui un sistema espone il proprio domain ai suoi consumatori |
| DTO | Data Transfer Object, design pattern usato per trasferire dati tra sottosistemi di un'applicazione software |
| HTTP | HyperText Transfer Protocol, protocollo a livello applicativo usato come principale sistema per la trasmissione d'informazioni sul web ovvero in un'architettura tipica client-server |
| HTTP Header | Componente della sezione header dei messaggi di request e response nel HyperText Transfer Protocol |
| JSON | JavaScript Object Notation, formato per lo scambio di dati |
| HTTP status code | Codice identificativo di un particolare stato emesso da un server in risposta alla richiesta di un client effettuata al servizio |
| Producer | Colui che definisce ed espone l’API |
| Consumer | Colui che consuma l’API |
| Resource | Entità di business, un’astrazione che si mappa su un repository tramite un layer intermedio |
| TLS | Transport Layer Security, protocollo crittografico |

## Storia delle modifiche

Nella seguente tabella è riportata la cronologia delle modifiche al presente documento.

| Data       | Autore       | Motivazione | Versione |
|------------|--------------|-------------|----------|
| 2025-07-17 | Gianni Mazzeo (Solution Architect)| Prima versione Draft | 0.1 |

# Prerequisiti

## Input richiesti al cliente

| Codice | Descrizione | Note |
|--------|------------|------|
| INP-F1 | Documento di analisi funzionale per ciascun FR (flussi, XSD, regole di business complete) con un livello di dettaglio tale che permetta la comprensione esaustiva del funzionamento delle routine senza dover fare reverse engineering dei programmi Cobol | Necessario per modellare i microservizi (API, mapping XML/REST/DB) |
| INP-F2 | Specifiche del servizio di validazione token (endpoint, formato token, SLA) | Indispensabile per implementare la sicurezza |
| INP-F3 | Dettagli schema DB2 e permessi di accesso | Non sono previste modifiche alle tabelle |
| INP-F4 | Finestre di manutenzione e SLA del gateway WZHC | Definisce parametri di timeout e retry |
| INP-F5 | Requisiti NFR numerici (TPS, dimensione payload, latenze massime) | Per capacity planning |
| INP-F6 | Linee guida per il CI/CD (eventuale accesso a OpenShift di DEV da concodare) | Necessita account con privilegi adeguati |

## Assunzioni e vincoli

Di seguito l'elenco di assunzioni e vincoli su cui si è basata la proposta di linee guida architetturali.

In caso di variazione di tali assunzioni, gli impatti di tempi, costi e qualità sono indicati nelle rispettive colonne con una _x_.

| ID | Descrizione                                                                                            | Tempi | Costi | Qualità | Note                                                                                           |
|----|--------------------------------------------------------------------------------------------------------|-------|-------|---------|------------------------------------------------------------------------------------------------|
| 1  | Lo schema DB2 non subirà variazioni                                                                    | x     | x     |         | Le variazioni dovranno essere valutate separatamente                                           |
| 2  | WZHC disponibile su rete interna, latenza < 500 ms                                                     | x     | x     | x       | Necessita valutazione e adozione di altre strategie, ad es. caching                            |
| 3  | Payload XML legacy non modificabile                                                                    | x     | x     |         | Modifiche al componente ACL da valutare e pianificare                                          |
| 4  | Politica di sicurezza secondo standard PizzaFichi SRL                                                             | x     | x     |         | Devono essere fornite le specifiche complete e in tempo utile                                  |
| 5  | Infrastruttura fornita e gestita dal cliente                                                           | x     | x     |         | La gestione dell'infrastruttura richiede competenze specifiche e pianificazione delle attività |


## RACI alto livello

| Attivita | Cliente | System Integrator |
|----------|---------|-----------|
| Fornitura documenti funzionali | A/R | C |
| Definizione architettura | C | A/R |
| Sviluppo microservizi | I | A/R |
| Amministrazione Infrastruttura | A/R | I |
| Specifiche di sicurezza | A/R | I |
| Installazione in produzione | A/R | C |

Legenda: **R** Responsible, **C** Consulted, **I** Informed, **A** Accountable


::: note
l'attività di _Sviluppo microservizi_ include sempre le seguenti:

- documentazione tecnica (markdown da caricare su wiki del cliente o export PDF in alternativa)
- sviluppo
- build
- unit-test
- push su repository del cliente
:::

---

# Overview Architetturale

## Principi architetturali guida

### API-First Design

Ogni componente deve essere progettato con un approccio API-first, garantendo:

- Contratti chiari e documentati (OpenAPI 3.1+)
- Versionamento semantico delle API
- Backward compatibility per ridurre gli impatti sui consumer esistenti
- Design RESTful seguendo il Richardson Maturity Model Level 2+

### Domain-Driven Design

I microservizi saranno strutturati seguendo i principi DDD:

- Identificazione chiara dei bounded context
- Separazione delle responsabilità per dominio di business
- Implementazione di pattern Anti-Corruption Layer per l'integrazione con sistemi legacy in ingresso

### Cloud-Native Patterns

Adozione di pattern specifici per ambienti cloud:

- Twelve-Factor App methodology
- Immutable infrastructure
- Configuration as code
- Stateless application design

### Linee guida per la definizione dei confini per la progettazione dei microservizi

Per il dominio di riferimento "Fornitori", la scelta architetturale predefinita è la realizzazione di un singolo microservizio, che espone tutte le funzionalità oggi esposte dai programmi cobol dedicati (DeliveryProject), salvo che emergano forti motivazioni architetturali per una suddivisione in più microservizi. La creazione di più microservizi sarà valutata solo in presenza di requisiti specifici che giustifichino la separazione (es. scalabilità autonoma, subdomini funzionali distinti con processi ad-hoc, requisiti di resilienza o compliance, necessità di evoluzione indipendente).

Questa scelta è guidata dai seguenti principi:

* **Ubiquitous Language e DDD**: i confini dei microservizi devono riflettere i bounded context del dominio, evitando frammentazioni artificiali.
* **Semplificazione operativa**: un singolo microservizio riduce la complessità di gestione, deployment e test, soprattutto in presenza di un unico schema DB2 condiviso.
* **Vincoli legacy**: la persistenza su DB2 e l'integrazione con WZHC impongono una coerenza transazionale che favorisce un approccio monolitico o single-service.
* **Testing e governance**: la strategia di test e la gestione delle dipendenze sono semplificate con un perimetro funzionale chiaro e unitario.

La suddivisione in più microservizi sarà adottata solo se porta un valore aggiunto concreto e misurabile, in linea con le best practice cloud-native e le esigenze di business. In assenza di tali motivazioni, la soluzione raccomandata è un unico microservizio **Fornitori-Microservice**.

Un componente di **Anti-Corruption Layer** garantisce che gli attuali software FR-Web ed altre dipendenze non abbiano regressioni, seguendo di fatto un approccio di tipo **hybrid-modernization** che consente una transizione graduale mantenendo la continuità operativa.

## Vista architetturale

```plantuml
@startuml
!include <c4/C4_Container.puml>

'icon reference: https://github.com/Roemer/plantuml-office

!include <office/Users/user.puml>
!include <office/Servers/server_generic.puml>
!include <office/Users/mobile_user.puml>
!include <office/Devices/device_tv.puml>
!include <office/Concepts/globe_internet.puml>
!include <office/Devices/device_phone_voip.puml>
!include <office/Concepts/settings.puml.puml>
!include <office/Security/lock_protected_blue.puml>
!include <office/Communications/3rd_party_service.puml>

skinparam nodesep 80
skinparam ranksep 50

title **Container View - To-Be**

Person(fr_user, "Utente", "Utente di FR-Web")
System(fr_web, "FR-Web", "Legacy Web Application", "globe_internet")
System_Boundary(open, "OpenShift") {
  Container(acl, "ACL Translator", "Spring Boot or Quarkus", "Converte richieste XML legacy in REST API", "settings") #green
  Container(fr_ms, "Microservice Fornitori", "Spring Boot", "Implementa le funzionalità dei diversi programmi FR", "settings") #green
  Container(sec, "Security Service", "Token validation", "Verifica token tecnico", "lock_protected_blue")
  note top
    Le specifiche del servizio di Verifica dei token di autenticazione saranno comunicate successivamente dal team ARK di PizzaFichi SRL
  end note
  Container(wzhc, "WZHC", "CICS/COBOL gateway", "Espone moduli COBOL via HTTP/XML", "3rd_party_service")
}

System_Boundary(cics, "HOST/CICS") {
  ContainerDb(db2, "FR DB", "DB2", "Database applicativo (Schema invariato)")
  Container(other, "Altri servizi SR, AG, BO, ecc.", "CICS", "Servizi che espongono dati di sola lettura e interrogati tramite il componente WZHC", "3rd_party_service")
}

' Aggiunta box "Sistemi che dipendono da Fornitori" con NA-Svcf e OpenBkg
System_Boundary(ext, "Sistemi che dipendono da Fornitori") {
  Container(na_svcf, "NA-Svcf", "N.A.", "Servizio PizzaFichi SRL proxy generico", "3rd_party_service") #grey
  Container(openbkg, "OpenBkg", "N.A.", "Servizio PizzaFichi SRL OpenBanking", "3rd_party_service") #grey
}
Rel(na_svcf, acl, "HTTP POST XML")
Rel(openbkg, acl, "HTTP POST XML")

Rel(fr_user, fr_web, "Utilizza UI")
Rel(fr_web, acl, "HTTP POST XML")
Rel(acl, fr_ms, "REST / JSON")
Rel_R(fr_ms, wzhc, "HTTP POST XML\n(La post viene utilizzata solo come canale di comunicazione per XML, al fine di uniformarci all'interfaccia esposta da WZHC)")
Rel(fr_ms, db2, "JDBC")
Rel_L(fr_ms, sec, "Token validation")
Rel(wzhc, other, "CTG/Driver")
@enduml
```

## Componenti architetturali in scope

### Microservice Fornitori

- **Tecnologia**: Spring Boot
- **Responsabilità**:
  - Esposizione API REST per le funzionalità di business
  - Orchestrazione delle chiamate verso sistemi legacy in sola lettura
  - Implementazione della business logic modernizzata
  - Gestione dello stato transazionale e scrittura su DB2
  - Caching intelligente per ottimizzazione performance

### Anti-Corruption Layer (ACL) Translator
- **Tecnologia**: Spring Boot
- **Responsabilità**:
  - Traduzione protocolli: XML ↔ JSON
  - Mapping dei data model legacy verso API moderne
  - Gestione della compatibilità all'indietro
  - Rate limiting e circuit breaker per protezione sistemi legacy (da valutare in corso d'opera)

---

## Scelte Tecnologiche

| Area | Scelta | Motivazione |
|------|--------|-------------|
| Runtime | Java 21 + acceleratori di microservizi es. Spring Boot | Startup rapida, footprint ridotto, supporto nativo framework di osservabilità (es. OpenTelemetry per integrazione con Dynatrace) |
| API | REST / JSON (Richardson Lvl 2) | Standard web, evoluzione semplice |
| Persistenza | IBM DB2 JDBC + JPA | Riuso schema esistente |
| Integrazione WZHC | HTTP POST XML (sync) | Integrazione tramite layer esistente PizzaFichi SRL |
| Observability | UUID di tracing negli header | Tracing end-to-end |

---

## Best Practice di Implementazione

### Progettazione delle REST API

* Versionamento esplicito (`/v1/...`).
* Nomi risorsa al plurale, evitare verbi nel path.
* Error model standard (`code`, `message`, `details`).
* Correlation-ID (`X-Request-Id`) propagato.
* Rate limiting a livello ingress (Route o API-Gateway).

### Integrazione con WZHC

* Command pattern per incapsulare chiamata e trasformazione XML.
* Timeout 2-5 s con retry limitato (solo operazioni di lettura).
* Circuit breaker con fallback HTTP 503.
* XSD versionato e validazione in/out.

### Accesso a DB2

* Transazioni brevi, commit immediato.
* Connection pool dimensionato via risorse pod.
* Optimistic locking dove applicabile.

### Sicurezza

* Token utente passato all'ACL -> viene propagato al servizio di business che lo verifica tramite servizio esterno. Politiche di caching da verificare.
* Secrets (credenziali DB2, chiavi JWT) in OpenShift Secrets.

::: warning
Le attività legate al perimetro di sicurezza saranno approfondite e valutate in seguito alla ricezione della documentazione PizzaFichi SRL.
:::

### Resilienza

| Failure scenario | Mitigazione |
|------------------|------------|
| WZHC non disponibile | Retry x3 con back-off, circuito aperto 30 s |
| DB2 lento | Timeout query, metriche di monitoraggio (es. Dynatrace) |
| Security service down | Cache autorizzazioni max 60 s, degrade 503 |

### Scope, responsabilità e criteri dei test di integrazione

I test di integrazione previsti saranno svolti sui seguenti ambiti, con l’obiettivo di verificare la corretta interazione tra i componenti principali e la raggiungibilità degli ambienti. Tutte le attività non esplicitamente elencate sono escluse dal perimetro (in particolare, non sono previsti test di performance).

**Test di integrazione previsti:**

- Verifica della comunicazione tra:
  - ACL Translator ↔ FR-Microservice (scambio XML/JSON)
  - FR-Microservice ↔ WZHC (HTTP POST XML)
  - FR-Microservice ↔ DB2 (connessione al database)
  - FR-Microservice ↔ Security Service (validazione token)
  - FR-Web ↔ ACL Translator (simulazione chiamate reali)
  - NS-Svcf ↔ ACL Translator (simulazione chiamate reali)
  - OpenBkg ↔ ACL Translator (simulazione chiamate reali)
- Simulazione di fault principali:
  - Indisponibilità temporanea di WZHC, DB2, Security Service (es. disconnessione, endpoint non raggiungibile)
  - Errori di configurazione (es. credenziali errate)
  - Verifica della gestione di timeout e errori di connessione

**Modalità di esecuzione:**

- I test saranno condotti manualmente o tramite strumenti di test standard, senza sviluppi ad hoc.
- Il numero di test sarà limitato ai flussi principali e ai fault concordati in fase di pianificazione (indicativamente 1 test per ciascun flusso e 1 test per ciascun fault critico).

**Responsabilità del cliente:**

- Predisporre e gestire l’ambiente di integrazione, inclusa la configurazione di tutti i sistemi coinvolti e la preparazione dei dati necessari.
- Fornire supporto operativo per eventuali ripristini, configurazioni o simulazioni di fault.

**Criteri di accettazione:**

- I test si considerano superati quando:
  - Tutti i componenti sono accessibili e comunicano correttamente secondo le specifiche.
  - Il sistema gestisce correttamente le principali condizioni di errore previste.
- Tutte le attività non esplicitamente elencate (es. test di performance, test funzionali approfonditi, ripristino ambienti, data preparation) sono escluse dal perimetro.

## Osservabilità

### Logging strutturato

* Formato JSON in console.
* Chiavi minime: timestamp, level, service, requestId, user, event.

### Tracing distribuito

* Generazione di header di tracciamento e correlazione

### Metriche applicative

* esposizione di metriche tramite esposizione `Spring Boot Actuator`
* da concordare tempi e costi di eventuali estensioni e personalizzazioni di metriche aggiuntive, non già incluse nel framework, che richiedessero sviluppi o personalizzazioni a codice

### Alerting e SLO

::: tip
Si consiglia di impostare un sistema di allarmi su Dynatrace allo scopo di reagire adeguatamente e prevedere quando possibile i guasti. Si consiglia inoltre la creazione di Dashboard Dynatrace ad-hoc per il perimetro progettuale di riferimento. Di seguito alcuni esempi, a solo scopo indicativo.
:::

> Esempio di metriche:

| Indicatore | Obiettivo | Trigger alert |
|------------|-----------|---------------|
| Availability FR-MS | >= 99.5 % | Error rate > 1 % per 5 min |
| P95 latency WZHC | < 800 ms | Latency > 1 s per 5 min |
| Heap usage | < 75 % | > 85 % per 15 min |
| DB Latency | < 500 ms | Latency > 1 s per 3 min


::: important
Le attività di configurazione, creazione dashboard e allarme sono escluse dal perimetro di offerta.
:::

---

# Governance e Documentazione

* Documentazione tecnica in template Markdown, preferibilmente da caricare sul wiki di compagnia (es. Gitlab, Confluence, ecc.)
* OpenAPI pubblicato su developer portal, change-log SemVer.
* Runbook per ogni microservizio (startup, health-check, errori comuni).
* Collegamento commit -> ticket (es. Jira).

---

# Deliverable previsti

| Milestone | Deliverable | Formato | Criterio di accettazione |
|-----------|------------|---------|-------------------------|
| Design | Specifiche OpenAPI per ogni FR | Swagger 2.0, OpenAPI 3.* | Validazione con team di business/ARK PizzaFichi SRL |
| Sviluppo | Documentazione e codice microservizi | Repository Git PizzaFichi SRL | Build e unit test verdi, coverage >= 80% |
| Test di Integrazione | Report test di integrazione | PDF | Superamento dei criteri descritti nel presente documento e in linea con quanto previsto dal perimetro di offerta |
| Go-live | Runbook operativo  | PDF | Firma di accettazione operativa |
---

# Conclusioni

La reingegnerizzazione DeliveryProject rappresenta più di una semplice migrazione tecnologica: è un'opportunità di trasformazione digitale che può posizionare PizzaFichi SRL all'avanguardia nel settore bancario. L'approccio consultivo proposto non si limita alla delivery tecnica, ma abbraccia un'visione olistica che include:

- **Architettura future-proof** basata su standard e best practice consolidate
- **Operational excellence** attraverso osservabilità avanzata e automation
- **Risk mitigation** attraverso strategie di migration graduali e testate
- **Knowledge transfer** per garantire autonomia e crescita interna
- **Continuous improvement** per mantenere il vantaggio competitivo nel tempo

Il successo di questo progetto creerà le fondamenta per ulteriori iniziative di modernizzazione e posizionerà PizzaFichi SRL come reference nel settore per l'adozione di tecnologie cloud-native nel banking.