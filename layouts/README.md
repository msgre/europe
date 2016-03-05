HTML verze jednotlivých typových obrazovek. Funkční v Chrome 49.

# Kompilace Less

1. Stáhnout Docker image
        docker pull ewoutp/lessc
2. Přidat alias do `~/.bash_profile` přidat
        alias lessc='docker run -it –rm -v $(pwd):$(pwd) -w $(pwd) ewoutp/lessc '
3. Vyzkoušet (v adresáři, kde je `styles.less`)
        lessc styles.less styles.css

# Automatická kompilace

Stáhnout `fswatch` a spustit v adresáři `css/`:

    fswatch -0 --include="\.less$" -o $PWD | xargs -0 -n 1 -I {} docker run -i --rm -v $PWD:$PWD -w $PWD ewoutp/lessc styles.less styles.css
