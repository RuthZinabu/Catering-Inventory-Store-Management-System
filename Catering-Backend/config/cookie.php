<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Cookie Settings
    |--------------------------------------------------------------------------
    |
    | This option determines the default settings that will be applied to all
    | cookies created by the application. You can override these settings
    | when creating individual cookies using the cookie helper methods.
    |
    */

    'path' => env('COOKIE_PATH', '/'),
    'domain' => env('COOKIE_DOMAIN'),
    'secure' => env('COOKIE_SECURE', true),
    'http_only' => env('COOKIE_HTTP_ONLY', true),
    'same_site' => env('COOKIE_SAME_SITE', 'lax'),
    'partitioned' => env('COOKIE_PARTITIONED', false),

];