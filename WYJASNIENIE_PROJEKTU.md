# Kompendium Projektu Big Data (Zestaw 23: cars-rentals)

Dokument zawiera kompletne wyjaśnienie działania obu etapów projektu:
1. **MapReduce Classic** (agregacja wypożyczeń per samochód i rok)
2. **Apache Hive** (rozbicie wyposażenia, łączenie i wyliczenie wskaźników ponadprzeciętnych)

---

# ETAP 1: MapReduce Classic

## 1. Cel etapu
Mamy 100 plików CSV (`rentals00.csv` do `rentals99.csv`), łącznie ok. 1,5 miliona wierszy z historii wypożyczalni.
Chcemy dla każdego samochodu (`car_id`) i każdego roku wypożyczenia (`rental_year`) obliczyć:
1. Łączną liczbę wypożyczeń (`total_rentals`).
2. Odsetek wypożyczeń zakończonych statusem `Completed` (`completed_ratio`).

Format wyjściowy (CSV bez spacji po przecinku):
```
CAR0001,2021,1045,0.3321
CAR0001,2024,936,0.3205
CAR0002,2020,255,0.3137
```

## 2. Architektura rozwiązania
Program składa się z 4 klas w Javie:
- **RentalMapper**: czyta linie CSV, ignoruje nagłówek, wyciąga rok z kolumny daty, emituje klucz `car_id,rok` oraz wartość `1,1` (jeśli Completed) lub `1,0` (jeśli inny status).
- **RentalCombiner**: agreguje częściowo wyniki lokalnie na węźle roboczym, sumując zliczenia wypożyczeń i liczbę statusów Completed. Nie liczy ułamka, aby nie zaburzyć średniej.
- **RentalReducer**: zbiera zsumowane wartości dla każdego klucza ze wszystkich węzłów, sumuje je ostatecznie, dzieli `completed / total` i formatuje wynik do 4 miejsc po przecinku (`0.0000`).
- **RentalStatsDriver**: konfiguruje zadanie w Hadoop YARN, wskazuje ścieżki w HDFS i ustawia separator wyjściowy na przecinek.

---

# ETAP 2: Apache Hive

## 1. Cel etapu
Mamy dwa źródła danych:
1. Wynik zadania MapReduce (`output/mapreduce_result`):
   `car_id, rental_year, total_rentals, completed_ratio`
2. Tabela samochodów (`datasource4/cars.csv`):
   `car_id, make, model, year, features, category`
   gdzie kolumna `features` zawiera listę wyposażenia rozdzieloną średnikami w cudzysłowie, np.:
   `"Bluetooth;Backup Camera;Keyless Entry"`

Cel:
Dla każdego pojedynczego elementu wyposażenia (`feature`) i każdego roku wypożyczenia (`rental_year`) policzyć:
- `feature_year_avg_rentals`: średnia liczba wypożyczeń samochodów z tą cechą w danym roku.
- `feature_year_avg_completed_ratio`: średni odsetek ukończonych wypożyczeń dla aut z tą cechą w danym roku.
- `above_avg_rentals`: flaga logiczna (`true` / `false`), informująca czy średnia liczba wypożyczeń w danym roku przewyższa ogólną średnią dla tego wyposażenia ze wszystkich lat.

## 2. Krok po kroku: Jak działa zapytanie HQL

### Krok A: Tabele zewnętrzne (EXTERNAL TABLE)
Tworzymy dwie tabele, które nie kopiują fizycznie plików do magazynu wewnętrznego Hive, lecz nakładają schemat na dane istniejące w HDFS:
- `rental_stats`: czyta bezpośrednio katalog wyjściowy z MapReduce (`ROW FORMAT DELIMITED FIELDS TERMINATED BY ','`).
- `cars_raw`: czyta plik `cars.csv` za pomocą standardowego formatu tekstowego (`ROW FORMAT DELIMITED FIELDS TERMINATED BY ','`).
- Cudzysłowy wokół wyposażenia są usuwane w locie w zapytaniu SQL (`regexp_replace(features, '"', '')`), a nagłówek pliku jest bezpiecznie odfiltrowywany (`WHERE trim(car_id) != 'car_id'`). To najbardziej niezawodne podejście w środowiskach rozproszonych, niewymagające żadnych zewnętrznych bibliotek SerDe.

### Krok B: Rozbicie listy wyposażenia (LATERAL VIEW explode)
Kolumna `features` zawiera string np. `"GPS;Sunroof;Bluetooth"`.
Funkcja `split(features, ';')` dzieli string na tablicę.
Konstrukcja `LATERAL VIEW explode(...)` powiela dany wiersz dla każdego elementu z tablicy:
- Samochód `CAR0005` z trzema cechami staje się 3 wierszami w tabeli tymczasowej.

### Krok C: Złączenie (JOIN)
Łączymy rozbite samochody z wynikami z MapReduce po `car_id`. Otrzymujemy wiersze zawierające: cechę, rok wypożyczenia, liczbę wypożyczeń i ratio ukończenia.

### Krok D: Agregacja roczna (GROUP BY feature, rental_year)
Grupujemy po parze `(feature, rental_year)` i wyliczamy:
- `AVG(total_rentals)` zaokrąglone do 2 miejsc po przecinku.
- `AVG(completed_ratio)` zaokrąglone do 4 miejsc po przecinku.

### Krok E: Funkcja okna (Window Function OVER PARTITION BY)
Aby sprawdzić, czy dany rok był powyżej średniej wieloletniej dla danej cechy, stosujemy funkcję okna:
`AVG(feature_year_avg_rentals) OVER (PARTITION BY feature)`
Dzięki temu nie musimy pisać osobnego zapytania z kolejnym GROUP BY – funkcja okna w locie oblicza średnią ze wszystkich lat dla danej cechy i pozwala na bezpośrednie porównanie w `CASE WHEN ... THEN true ELSE false END`.

---

# Jak uruchomić projekt w środowisku BigData25

## 1. Wejście do kontenera `master`
Na maszynie wirtualnej Debian:
```bash
docker compose exec -it master bash
```

## 2. Uruchomienie Etapu 1 (MapReduce)
```bash
cd ~/big-data-project/mapreduce
chmod +x *.sh
./run_all.sh
```

## 3. Uruchomienie Etapu 2 (Hive)
```bash
cd ~/big-data-project/hive
chmod +x *.sh
./run_all.sh
```

Wyniki Hive zostaną wyświetlone na konsoli oraz automatycznie wyeksportowane do pliku:
`hive/result/hive_output.csv`
