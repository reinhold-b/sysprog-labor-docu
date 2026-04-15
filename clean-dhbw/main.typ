#import "@preview/clean-dhbw:0.4.0": *
#import "glossary.typ": glossary-entries

#show: clean-dhbw.with(
  title: "Systemnahe Programmierung mit dem ESP32C3",
  authors: (
    (name: "Max Mustermann", student-id: "7654321", course: "TINF22B2", course-of-studies: "Informatik", company: (
      (name: "ABC GmbH", post-code: "76131", city: "Stuttgart")
    )),
    // (name: "Juan Pérez", student-id: "1234567", course: "TIM21", course-of-studies: "Mobile Computer Science", company: (
    //   (name: "ABC S.L.", post-code: "08005", city: "Barcelona", country: "Spain")
    // )),
  ),
  type-of-thesis: "Dokumentation",
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries, // displays the glossary terms defined in "glossary.typ"
  language: "de", // en, de
  supervisor: (company: "John Appleseed", university: "Prof. Dr. Daniel Düsentrieb"),
  university: "Duale Hochschule Baden-Württemberg",
  university-location: "Stuttgart",
  university-short: "DHBW",
  // for more options check the package documentation (https://typst.app/universe/package/clean-dhbw)
)

// Edit this content to your liking

= Laboraufgabe 1
Die Erweiterung mit dem Poti schalten wir für die Laboraufgabe 2 aus.
= Laboraufgabe 2
Zuerst enablen wir die GPIO out Pins mit `*GPIO_ENABLE_REG = 0b00001010;` für den Poti und das USS Init Signal.
Um den Initialburst zu schicken, muss der ESP ein mindestens $10 "μs"$ langes Signal bereitstellen. Dafür nutzen wir `GPIO3`. Der USS sendet nach seiner Messung ein Echo, welches wir auf `GPIO2` auslesen. werden. Wir nutzen `*GPIO_OUT_REG |= (1 << 3);` um den Port auf `HIGH` zu setzen und warten dann mit einer For-Schleife die benötigte Zeit. Danach setzen wir mit `*GPIO_OUT_REG &= tilde(1 << 3);` auf 0.

Nach dem Initialburst sendet der USS Bursts. In der Zeit ist auf dem `GPIO3` kein Signal. Wir nutzen `int isEchoing = (*GPIO_IN_REG & (1 << 2));` um den Status des Outsignals des USS zu prüfen. In einer While-Schleife warten wir, solange kein Echo vorliegt. In einer weiteren warten wir danach, solange das Signal läuft. In der Zeit nutzen wir einen Timer, um die Zeit des Signals zu messen. 

Um den Timer aufzusetzen, setzen wir zuerst den Divider auf 2 mit `TIMG_T0CONFIG_REG |= (1 << 13);` und den RST mit `TIMG_T0CONFIG_REG |= (1 << 12);`. Zu jeder Mainloop-Iter resetten wir den Timer, sodass er mit null startet: `*TIMG_T0LOADLO_REG = 0;` und `*TIMG_T0LOAD_REG = 1;`, damit der Timer den Loadwert übernimmt. Dann können wir den Timer nutzen, um in unserem zweiten While-Loop die Länge des Echos zu messen. Wir starten bei Start des Echos den Timer `*TIMG_T0CONFIG_REG |= (1 << 31);`. Nachdem das Echo zuende ist, schalten wir den Timer aus `*TIMG_T0CONFIG_REG &= tilde(1 << 31);` und dann latchen ans Hi und Lo Register: `TIMG_T0UPDATE_REG |= (1 << 31);`. Dann lesen wir `value = *TIMG_T0LO_REG`.

Wir berechnen den Millimeterwert wie folgt: $"value" * frac(1 * 1000000, 40 * 1000000) = "value" / 40 "us" -> "dist_mm" = "time_us" / 58 * 10 "mm"$.

Um die LEDs anzusteuern, berechnen wir einen Anteil $"dist" / "validRange"$ wobei die valide Range zwischen 5 und 50 liegt. Damit berechnen wir den Index der LEDs, bis zu dem die LEDs leuchten sollen (siehe Code). 

Danach wollen wir die LEDs von Grün zu Rot faden, je nachdem wie nah das Objekt ist. Wir nutzen den berechneten Faktor, um bei Ansteuerung der LEDs den Grünwert mit `factor` zu multiplizieren und den Rotwert mit `1 - factor`. Somit "mischen" wir die Farben.

== Programm Quellcode

Quellcode mit entsprechender Formatierung wird wie folgt eingefügt:

#figure(
  caption: "Ein Stück Quellcode",
  sourcecode[```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
    ```],
)


== Verweise

Für Literaturverweise verwendet man die `cite`-Funktion oder die Kurzschreibweise mit dem \@-Zeichen:
- `#cite(form: "prose", <iso18004>)` ergibt: \ #cite(form: "prose", <iso18004>)
- Mit `@iso18004` erhält man: @iso18004