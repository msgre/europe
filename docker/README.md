Jak rozjet a pracovat s kontejnerem pro evropu
==============================================

1. Nejdriv je treba pripravit Docker image. To chvili trva. Spust
   `./build.sh`

   Dojde k nakopirovani Pythonich requirements souboru z projektu europe
   a zbuildeni Docker image pod nazvem "msgre/europe".

2. Spust ./run.sh

   Spusti se kontejner se jmenem "europe", odvozeny z image "msgre/europe", do
   ktereho je nasdilen adresar se zdrojovymi kody projektu.
   Kontos se pricmrdne na port 8000 hosta.
   Vevnitr jede Djangoidni devel server, v konzoli budou objevovat stdout
   hlasky zevnitr kontejneru (vystup runserver).

3. Spust ./nginx.sh

   Naskoci kontejner s Nginxem, do ktereho jsou nasdileny 2 veci:

   * Zdrojove kody javascriptove aplikace z adresare `static/`. Tento obsah
     bude dostupny na portu 80.
   * Konfigurace Nginxe, ktery jednak zaridi servirovani statickeho obsahu
     z predchoziho bodu, ale taky zpristupni Django REST API z portu 8000
     primo pod port 80.

4. Pokud mas potrebu vlezt do Django konzole, spust `./shell.sh`


Jak to facha
------------

V Dockerfile nejde skoro nic videt. Je to proto, ze bazovy image pouziva konstrukce
`ONBUILD` diky kterym se dovnitr image foukne soubor requirements.txt (do adresare
`/usr/src/app`), s pomoci `pip-u` se nainstaluji balicky a do stejneho adresare
nakopiruje context (rizeny `build.sh` skriptem, ktery do kontextu dava pouze
`Dockerfile` a `requirements.txt`) **az behem buildovani odvozeneho image**.

Obsah `/usr/src/app` pak v runtime kontejneru prebijim zdrojakama z matky.

Nginx
-----

Tohle je srandovni. Konfigurace v propojeni 80->8000 je realizovana nejak takto:

    location ~ ^/api {
      proxy_pass http://europe:8000;
      proxy_read_timeout 90;
    }

Vsimni si `proxy_pass`. Puvodne jsem tam mel 0.0.0.0:8000 ale nefachalo to
(bo on se chce pripojit sam na sebe, na nginx kontos; appka ale jede vne, v jinem
kontejneru). Pak jsem si vzpomnel, ze pri prolinkovani kontejneru se nastavuji 
jednak ENV promenne, ale zaroven dochazi k upravam `/etc/hosts` a toho prave vyuzivam.
`proxy_pass` se smeruje na kontos "europe" coz je alias z `/etc/hosts`.
