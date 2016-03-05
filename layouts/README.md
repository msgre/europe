HTML versions of [screens](screens/). Functional in Chrome 49.

# Less compilation

1. Pull Docker image  

        docker pull ewoutp/lessc
        
2. Add alias into `~/.bash_profile`  
        
        alias lessc='docker run -it –rm -v $(pwd):$(pwd) -w $(pwd) ewoutp/lessc '
3. Test it (in [css](css/) folder, next to `styles.less` file)  

        lessc styles.less styles.css

# Atomatic compilation

Install `fswatch` into your OS and run following command in `css/` folder:

    fswatch -0 --include="\.less$" -o $PWD | xargs -0 -n 1 -I {} docker run -i --rm -v $PWD:$PWD -w $PWD ewoutp/lessc styles.less styles.css
