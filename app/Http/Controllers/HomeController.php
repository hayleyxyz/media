<?php
/**
 * Created by PhpStorm.
 * User: oscar
 * Date: 09/02/2016
 * Time: 01:54
 */

namespace App\Http\Controllers;


use Illuminate\Http\Request;

class HomeController extends Controller{

    public function getUpload(Request $request) {
        return view('upload');
    }

}