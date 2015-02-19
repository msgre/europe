Jak rozjet a pracovat s kontejnerem pro evropu
==============================================

1. Nejdriv je treba pripravit Docker image. To chvili trva. Spust
   `./build.sh`

   Dojde k nakopirovani Pythonich requirements souboru z projektu europe
   a zbuildeni Docker image pod nazvem "msgre/europe".

2. Spust ./run.sh

   Spusti se kontejner se jmenem "europe", odvozeny z image "msgre/europe", do
   ktereho je nasdilen adresar se zdrojovymi kody projektu.
   Kontos se pricmrdne na port 8000 hosta a je dostupny z vnejsi (tj. pokud
   na kontos chci sahnout zevnitr VBoxu kontaktuji 0.0.0.0:8000, pokud z vnejsku
   pak pres IP:8000).Napr. `curl -XGET 172.17.0.71:8000`.
   Vevnitr jede Djangoidni devel server, v konzoli budou objevovat stdout
   hlasky zevnitr kontejneru (vystup runserver).

3. Pokud mas potrebu vlezt do Django konzole, spust `./shell.sh`


Jak to facha
------------

V Dockerfile nejde skoro nic videt. Je to proto, ze bazovy image pouziva konstrukce
`ONBUILD` diky kterym se dovnitr image foukne soubor requirements.txt (do adresare
`/usr/src/app`), s pomoci `pip-u` se nainstaluji balicky a do stejneho adresare
nakopiruje context (rizeny `build.sh` skriptem, ktery do kontextu dava pouze
`Dockerfile` a `requirements.txt`) **az behem buildovani odvozeneho image**.

Obsah `/usr/src/app` pak v runtime kontejneru prebijim zdrojakama z matky.
