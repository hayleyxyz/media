<?php

Route::group(['middleware' => ['web']], function () {

    Route::get('upload', 'HomeController@getUpload');

});
