<?php
include "dbconn.php";
?>

<!DOCTYPE html>
<html>
	<head>
		<title>Regesta - Dev Test</title>
		<link rel="stylesheet" type="text/css" href="style.css">
		<script>
			<!-- AJAX function, dynamically get best supplier -->
			function checkQuantity(item, quantity) {
				if (item == "") {
					alert("Missing item!");
				} else if (quantity == "") {
					alert("Missing quantity!");
				} else {
					var xmlhttp = new XMLHttpRequest();
					xmlhttp.onreadystatechange = function() {
						if (this.readyState == 4 && this.status == 200) {
							document.getElementById("best").innerHTML = this.responseText;
						}
					};
					xmlhttp.open("GET","getbest.php?q="+item+"&w="+quantity,true);
					xmlhttp.send();
				}
			}
		</script>
	</head>
	<body>
		<h1>Regesta - Dev Test</h1>
		<form action="index.php" method="post">
			<h2>Select item and quantity:</h2>
			<h3>Item:</h3>
			<?php
				echo '<select name="items" id="items" placeholder="Item">';
				echo '<option value="">*Select an item:</option>';
				if($result = mysqli_query($conn, $sql)){
					if(mysqli_num_rows($result) > 0){
						while($row = mysqli_fetch_array($result)){
							echo '<option value="' . $row['ID'] . '">' . $row['SPECS'] . '</option>';
						}
						mysqli_free_result($result);
					} else{
						echo "No records matching your query were found.";
					}
				} else{
					echo "ERROR: Could not execute $sql. " . mysqli_error($mysql_connection);
				}
				echo '</select>';
			?>

			<h3>Quantity:</h3>
			<input type="number" name="quantity" placeholder="Quantity">

			<!-- AJAX call on button click-->
			<button type="button" name="submit" onclick="checkQuantity(items.value, quantity.value)">Get available suppliers</button>
		</form>
		<div id="best"></div>
	</body>
</html>