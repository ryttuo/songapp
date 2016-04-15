<?php 
    /*
    Plugin Name: SongApp-API
    Plugin URI: 
    Description: Custom plugin to create an RESTful API for songapp 
    Author: Andrés Solano S
    Version: 1.0
    Author URI:
    */


add_filter('json_api_encode', 'json_api_encode_acf');

function json_api_encode_acf($response) 
{
    if (isset($response['posts'])) {
        foreach ($response['posts'] as $post) {
            json_api_add_acf($post); // Add specs to each post
        }
    } 
    else if (isset($response['post'])) {
        json_api_add_acf($response['post']); // Add a specs property
    }

    return $response;
}

function json_api_add_acf(&$post) 
{
    $post->acf = get_fields($post->id);
}
