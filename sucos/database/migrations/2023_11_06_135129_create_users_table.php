<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id('id_user');
            $table->string('id_staff')->unique();
            $table->string('password');
            $table->string('nama');
            $table->enum('jenis_kelamin', ['Laki-laki', 'Perempuan']);
            $table->string('alamat');
            $table->string('no_tlp')->unique();
            $table->string('foto')->default('null');
            $table->string('email')->unique();
            $table->enum('status', ['aktif', 'tidak-aktif']);
            $table->enum('roles', ['marketing', 'supervisor', 'leader', 'staff_gudang', 'kepala_gudang', 'admin']);
            $table->timestamps();
        });
        // Menambahkan satu data default
        // User::table('users')->insert([
        //     'id_staff' => '123',
        //     'password' => bcrypt('admin1'), // Anda mungkin ingin mengenkripsi kata sandi
        //     'nama' => '123',
        //     'jenis_kelamin' => 'Laki-laki', // Sesuaikan dengan kebutuhan
        //     'alamat' => 'Default',
        //     'no_tlp' => '1234567890',
        //     'foto' => 'default-profile.jpg', // Ganti dengan nama file foto default
        //     'email' => 'admin1@gmail.com.com',
        //     'status' => 'aktif', // Sesuaikan dengan kebutuhan
        //     'roles' => 'admin', // Sesuaikan dengan kebutuhan
        //     'created_at' => now(),
        //     'updated_at' => now(),
        // ]);
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
