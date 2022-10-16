<?php
include "dbconn.php";
?>

<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" type="text/css" href="style.css">
	</head>
	<body>
		<?php
			$item = intval($_GET['q']);
			$quantity = intval($_GET['w']);
			$datetime = date('y-m-d h:i:s');
			
			// Prepare call to stored procedure GetBestSupplier
			$call = mysqli_prepare($conn, 'CALL GetBestSupplier(?, ?, ?)');
			mysqli_stmt_bind_param($call, 'iis', $item, $quantity, $datetime);

			mysqli_stmt_execute($call);
			$result = mysqli_stmt_get_result($call);
			
			echo '<h3>Available suppliers (highlighted in green the cheapest):</h3>
				<table>
					<tr>
						<th>BUSINESS NAME</th>
						<th>INITIAL PRICE</th>
						<th>DISCOUNT %</th>
						<th>FINAL PRICE</th>
						<th>SHIP DAYS</th>
					</tr>';				
			
			$counter = 0;
			
			// Fetch result (first row is the cheapest supplier)
			while ($row = mysqli_fetch_array($result, MYSQLI_NUM)) {
				$counter ++;
				if ($counter == 1) {
					echo '<tr>';
					echo '<td class="highlight">' . $row[0] . '</td>';
					echo '<td>' . $row[1] . '</td>';
					echo '<td>' . $row[2] . '</td>';
					echo '<td class="highlight">' . $row[3] . '</td>';
					echo '<td>' . $row[4] . '</td>';
					echo '</tr>';
				} else {
					echo '<tr>';
					echo '<td>' . $row[0] . '</td>';
					echo '<td>' . $row[1] . '</td>';
					echo '<td>' . $row[2] . '</td>';
					echo '<td>' . $row[3] . '</td>';
					echo '<td>' . $row[4] . '</td>';
					echo '</tr>';
				}
			}
			echo '</table>';

			mysqli_free_result($result);
			mysqli_close($conn);
		?>		
	</body>
</html>