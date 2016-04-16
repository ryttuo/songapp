<?php 
    /*
    Plugin Name: SongApp-API
    Plugin URI: 
    Description: Custom plugin to create an RESTful API for songapp 
    Author: Andrés Solano S
    Version: 1.0
    Author URI:
    */


function register_post_custom_field() {
    register_api_field( 'post',
        'custom_field',
        array(
            'get_callback'    => 'get_custom_field',
            'update_callback' => null,
            'schema'          => null,
        )
    );
}

function get_custom_field( $object, $field_name, $request ) {
    return get_post_meta( $object[ 'id' ], $field_name, true );
}

add_action( 'rest_api_init', function () {
        register_rest_route( 'myplugin/v1', '/author/(?P\d+)', array(
            'methods' => 'GET',
            'callback' => 'get_post_title_by_author'
        ) );
} );
        
        
function get_post_title_by_author( $data ) {
    $posts = get_posts( array(
        'author' => $data['id'],
    ) );

    if ( empty( $posts ) ) {
        return null;
    }

    return $posts[0]->post_title;
}
