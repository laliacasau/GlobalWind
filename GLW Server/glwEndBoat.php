<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
$data       = file_get_contents("php://input");
$cols       = explode(",",$data);
require '../../glwdb.php';

$idEvents=$cols[0];
$idBoats=$cols[1];

$sql = "DELETE FROM glwBoats WHERE id=".$idBoats." AND idEvents=".$idEvents;
if ($conn->query($sql) === TRUE) {
    print "OK";
} else {
    $conn->close();
    die("KOEndEvent Error1: " . $sql . "\n" . $conn->error);
}
$conn->close();
?>