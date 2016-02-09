<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateMediaTagTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('media_tag', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('media_id')->unsigned();
            $table->foreign('media_id')->references('id')->on('media');
            $table->integer('tag_id')->unsigned();
            $table->foreign('tag_id')->references('id')->on('tags');
            $table->integer('tag_namespace_id')->unsigned()->nullable();
            $table->foreign('tag_namespace_id')->references('id')->on('tag_namespaces');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('media_tag');
    }
}
