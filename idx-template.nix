{ pkgs, clientVersion, clientPackage, serverVersion, version ? "latest", ... }: {

    packages = [
      pkgs.php82
      pkgs.php82Packages.composer
      pkgs.nodejs_20
    ];

    bootstrap = ''
      mkdir composer-home
      export COMPOSER_HOME=./composer-home
			mkdir "$out"
      composer create-project laravel/laravel "$out"
			mkdir -p "$out"/.idx
  		cp ${./dev.nix} "$out"/.idx/dev.nix
      mkdir -p "$out"/resources/js/Pages
      cp ${./resources/${clientPackage}/app.js} "$out"/resources/js/app.js
      cp ${./resources/${clientPackage}/Welcome.${if clientPackage == "react" then "jsx" else if clientPackage == "vue3" then "vue" else "svelte"}} "$out"/resources/js/Pages
      cp ${./resources/app.blade.php} "$out"/resources/views/app.blade.php
      cp ${./resources/app.php} "$out"/bootstrap/app.php
      cp ${./resources/web.php} "$out"/routes/web.php
      cd "$out"
      composer require inertiajs/inertia-laravel:${if serverVersion == "2.x" then "2.x-dev" else serverVersion}
      php artisan inertia:middleware
      npm install @inertiajs/${clientPackage}@${clientVersion}
      npm install vite laravel-vite-plugin
      npm install @vitejs/plugin-${if clientPackage == "vue3" then "vue" else clientPackage}
    '';
}
