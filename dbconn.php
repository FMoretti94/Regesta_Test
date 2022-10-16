<?php

$host= "localhost";
$username= "test";
$password = "R3g3st4T3st!";

$db_name = "regestatest";

// Establish DB connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if (!$conn) {
  die("Connection failed: " . mysqli_connect_error());
}

// Get all items availavle
$sql = "SELECT * FROM item order by BRAND, MODEL";